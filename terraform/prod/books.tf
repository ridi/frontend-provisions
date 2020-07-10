locals {
  books_hostname     = "books.ridibooks.com"
  books_lb_origin_id = "books-lb-origin"
  books_s3_origin_id = "books-s3-origin"
  stage_lambda = {
    prod       = "books-production-server"
    prerelease = "books-prerelease-server"
  }
}

resource "aws_s3_bucket" "books" {
  bucket = "ridi-books-prod"
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
    aws_subnet.main["ap-northeast-2a"].id,
    aws_subnet.main["ap-northeast-2b"].id,
    aws_subnet.main["ap-northeast-2c"].id,
  ]
  security_groups = [aws_security_group.books-alb.id]
}

resource "aws_lb_listener" "books" {
  load_balancer_arn = aws_lb.books.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.books["prod"].arn
  }
}

resource "aws_lb_listener_rule" "books-prerelease" {
  listener_arn = aws_lb_listener.books.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.books["prerelease"].arn
  }

  condition {
    http_header {
      http_header_name = "cookie"
      values           = ["*stage=prerelease*"]
    }
  }
}

resource "aws_lb_target_group" "books" {
  for_each = local.stage_lambda

  name        = "books-${each.key}"
  target_type = "lambda"
}

resource "aws_lb_target_group_attachment" "books" {
  for_each = local.stage_lambda

  target_group_arn = aws_lb_target_group.books[each.key].arn
  target_id        = data.aws_lambda_function.books[each.key].arn
  depends_on       = [aws_lambda_permission.books]
}

resource "aws_lambda_permission" "books" {
  for_each = local.stage_lambda

  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.books[each.key].arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.books[each.key].arn
}

data "aws_lambda_function" "books" {
  for_each      = local.stage_lambda
  function_name = each.value
}

# CloudFront Distribution
resource "aws_cloudfront_origin_access_identity" "books" {}

resource "aws_cloudfront_distribution" "books-ridibooks-com" {
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

  origin {
    domain_name = "s17jeqop1d.execute-api.ap-northeast-2.amazonaws.com"
    origin_id   = "Custom-s17jeqop1d.execute-api.ap-northeast-2.amazonaws.com/production"
    origin_path = "/production"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2"
      ]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = [local.books_hostname, "ridibooks.com"]

  default_cache_behavior {
    allowed_methods = ["HEAD", "GET"]
    cached_methods  = ["HEAD", "GET"]

    target_origin_id = "Custom-s17jeqop1d.execute-api.ap-northeast-2.amazonaws.com/production"

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
    path_pattern = "/_next/*"

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
    acm_certificate_arn      = aws_acm_certificate.ridibooks-com.arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }

  depends_on = [aws_s3_bucket_policy.books]
}
