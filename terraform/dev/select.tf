locals {
  select_s3_origin_id = "select-s3-origin"
}

resource "aws_s3_bucket" "select" {
  bucket = "ridi-select-dev"
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
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.select.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.select.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.select.iam_arn}"]
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "select" {}

resource "aws_cloudfront_distribution" "select-ridi-io" {
  origin {
    domain_name = "${aws_s3_bucket.select.bucket_regional_domain_name}"
    origin_id   = "${local.select_s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.select.cloudfront_access_identity_path}"
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

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

  default_root_object = "index.html"

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  web_acl_id = "${module.common.in_office_waf_acl_id}"
}
