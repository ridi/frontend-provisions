locals {
  books_staging_hostname     = "books-staging.ridibooks.com"
  books_staging_lb_origin_id = "books-staging-lb-origin"
  books_staging_s3_origin_id = "books-staging-s3-origin"
}

resource "aws_s3_bucket" "books-staging" {
  bucket = "ridi-books-staging"
}

resource "aws_s3_bucket_policy" "books-staging" {
  bucket = aws_s3_bucket.books-staging.id
  policy = data.aws_iam_policy_document.books-staging.json
}

data "aws_iam_policy_document" "books-staging" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.books-staging.arn}/_next/*"]

    principals {
      type        = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.books-staging.iam_arn
      ]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.books-staging.arn]

    principals {
      type        = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.books-staging.iam_arn
      ]
    }
  }
}

# CloudFront Distribution
resource "aws_cloudfront_origin_access_identity" "books-staging" {}

resource "aws_cloudfront_distribution" "books-staging-ridibooks-com" {
  origin {
    domain_name = aws_s3_bucket.books-staging.bucket_regional_domain_name
    origin_id   = local.books_staging_s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.books.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = [local.books_staging_hostname]

  default_cache_behavior {
    allowed_methods = ["HEAD", "GET"]
    cached_methods  = ["HEAD", "GET"]

    target_origin_id = local.books_staging_lb_origin_id

    forwarded_values {
      query_string            = true
      query_string_cache_keys = ["is_login"]

      cookies {
        forward           = "whitelist"
        whitelisted_names = ["ridi_app_theme", "stage"]
      }
    }

    viewer_protocol_policy = "allow-all"
  }

  ordered_cache_behavior {
    path_pattern = "/search"

    allowed_methods = ["HEAD", "GET"]
    cached_methods  = ["HEAD", "GET"]

    target_origin_id = local.books_staging_lb_origin_id

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

    target_origin_id = local.books_staging_lb_origin_id

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
    target_origin_id = local.books_staging_s3_origin_id
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

  depends_on = [aws_s3_bucket_policy.books-staging]
}
