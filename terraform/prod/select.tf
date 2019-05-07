locals {
  select_s3_origin_id = "select-s3-origin"
}

resource "aws_s3_bucket" "select" {
  bucket = "ridi-select-prod"

  website {
    index_document = "index.html"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://select.ridibooks.com"]
  }
}

resource "aws_s3_bucket_policy" "select" {
  bucket = "${aws_s3_bucket.select.id}"
  policy = "${data.aws_iam_policy_document.select.json}"
}

data "aws_iam_policy_document" "select" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.select.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "select" {}

resource "aws_cloudfront_distribution" "select-ridicdn-net" {
  origin {
    domain_name = "${aws_s3_bucket.select.bucket_regional_domain_name}"
    origin_id   = "${local.select_s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.select.cloudfront_access_identity_path}"
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["select.ridicdn.net"]

  default_cache_behavior {
    allowed_methods = ["HEAD", "GET"]
    cached_methods  = ["HEAD", "GET"]
    compress        = false

    target_origin_id = "${local.select_s3_origin_id}"

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
    cloudfront_default_certificate = true
  }
}
