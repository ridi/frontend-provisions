locals {
  books_hostname     = "books.ridi.io"
  books_s3_origin_id = "books-s3-origin"
}

resource "aws_s3_bucket" "books" {
  bucket = "ridi-books-dev"
}

# Load Balancer
resource "aws_lb" "books" {
  name    = "books"
  subnets = [
    "${aws_subnet.ap-northeast-2a.id}",
    "${aws_subnet.ap-northeast-2b.id}",
  ]
}

resource "aws_lb_listener" "books" {
  load_balancer_arn = "${aws_lb.books.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.books-development.arn}"
  }
}

resource "aws_lb_listener_rule" "staging" {
  listener_arn = "${aws_lb_listener.books.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.books-staging.arn}"
  }

  condition {
    http_header {
      http_header_name = "cookie"
      values           = ["*stage=staging*"]
    }
  }
}

resource "aws_lb_target_group" "books-development" {
  name        = "books-development"
  target_type = "lambda"
}

resource "aws_lb_target_group" "books-staging" {
  name        = "books-staging"
  target_type = "lambda"
}

resource "aws_lb_target_group_attachment" "books-development" {
  target_group_arn = "${aws_lb_target_group.books-development.arn}"
  target_id        = "${data.aws_lambda_function.books-development.arn}"
  depends_on       = ["aws_lambda_permission.with_development"]
}

resource "aws_lb_target_group_attachment" "books-staging" {
  target_group_arn = "${aws_lb_target_group.books-staging.arn}"
  target_id        = "${data.aws_lambda_function.books-staging.arn}"
  depends_on       = ["aws_lambda_permission.with_staging"]
}

resource "aws_lambda_permission" "with_development" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = "${data.aws_lambda_function.books-development.arn}"
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = "${aws_lb_target_group.books-development.arn}"
}

resource "aws_lambda_permission" "with_staging" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = "${data.aws_lambda_function.books-staging.arn}"
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = "${aws_lb_target_group.books-staging.arn}"
}

data "aws_lambda_function" "books-development" {
  function_name = "books-development-server"
}

data "aws_lambda_function" "books-staging" {
  function_name = "books-staging-server"
}
