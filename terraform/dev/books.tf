locals {
  books_hostname     = "books.ridi.io"
  books_lb_origin_id = "books-lb-origin"
  books_s3_origin_id = "books-s3-origin"
}

resource "aws_s3_bucket" "books" {
  bucket = "ridi-books-dev"
}

resource "aws_s3_bucket_policy" "books" {
  bucket = aws_s3_bucket.books.id
  policy = data.aws_iam_policy_document.books.json
}

data "aws_iam_policy_document" "books" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.books.arn}/_next/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.books.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.books.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.books.iam_arn]
    }
  }
}

# Load Balancer
resource "aws_lb" "books" {
  name = "books"
  subnets = [
    aws_subnet.main-new["ap-northeast-2a"].id,
    aws_subnet.main-new["ap-northeast-2b"].id,
  ]
  security_groups = [aws_security_group.books-alb.id]
}

resource "aws_lb_listener" "books" {
  load_balancer_arn = aws_lb.books.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.books-development.arn
  }
}

resource "aws_lb_listener_rule" "staging" {
  listener_arn = aws_lb_listener.books.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.books-staging.arn
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
  target_group_arn = aws_lb_target_group.books-development.arn
  target_id        = data.aws_lambda_function.books-development.arn
  depends_on       = ["aws_lambda_permission.with_development"]
}

resource "aws_lb_target_group_attachment" "books-staging" {
  target_group_arn = aws_lb_target_group.books-staging.arn
  target_id        = data.aws_lambda_function.books-staging.arn
  depends_on       = ["aws_lambda_permission.with_staging"]
}

resource "aws_lambda_permission" "with_development" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.books-development.arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.books-development.arn
}

resource "aws_lambda_permission" "with_staging" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.books-staging.arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.books-staging.arn
}

data "aws_lambda_function" "books-development" {
  function_name = "books-development-server"
}

data "aws_lambda_function" "books-staging" {
  function_name = "books-staging-server"
}

# CloudFront Distribution
resource "aws_cloudfront_origin_access_identity" "books" {}

resource "aws_cloudfront_distribution" "books-ridi-io" {
  origin {
    domain_name = aws_lb.books.dns_name
    origin_id   = local.books_lb_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = aws_s3_bucket.books.bucket_regional_domain_name
    origin_id   = local.books_s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.books.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = [local.books_hostname]

  default_cache_behavior {
    allowed_methods = ["HEAD", "GET"]
    cached_methods  = ["HEAD", "GET"]

    target_origin_id = local.books_lb_origin_id

    forwarded_values {
      query_string            = true
      query_string_cache_keys = ["is_login"]

      cookies {
        forward           = "whitelist"
        whitelisted_names = ["stage"]
      }
    }

    viewer_protocol_policy = "allow-all"
  }

  ordered_cache_behavior {
    path_pattern = "/partials/gnb"

    allowed_methods = ["HEAD", "GET"]
    cached_methods  = ["HEAD", "GET"]

    target_origin_id = local.books_lb_origin_id

    forwarded_values {
      query_string = true

      cookies {
        forward           = "whitelist"
        whitelisted_names = ["stage"]
      }
    }

    viewer_protocol_policy = "allow-all"
  }

  ordered_cache_behavior {
    path_pattern     = "/_next/*"
    allowed_methods  = ["HEAD", "GET"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = local.books_s3_origin_id
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.ridi-io.arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }

  depends_on = [aws_s3_bucket_policy.books]
}
