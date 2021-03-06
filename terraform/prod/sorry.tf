locals {
  sorry_s3_origin_id = "sorry-s3-origin"
}

resource "aws_s3_bucket" "sorry" {
  bucket = "ridi-sorry-prod"
}

resource "aws_s3_bucket_policy" "sorry" {
  bucket = "${aws_s3_bucket.sorry.id}"
  policy = "${data.aws_iam_policy_document.sorry.json}"
}

data "aws_iam_policy_document" "sorry" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.sorry.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.sorry.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.sorry.arn}"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.sorry.iam_arn]
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "sorry" {}

resource "aws_cloudfront_distribution" "sorry-ridibooks-com" {
  origin {
    domain_name = "${aws_s3_bucket.sorry.bucket_regional_domain_name}"
    origin_id   = "${local.sorry_s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.sorry.cloudfront_access_identity_path}"
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["sorry.ridibooks.com"]

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

    target_origin_id = "${local.sorry_s3_origin_id}"

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
    acm_certificate_arn      = "${aws_acm_certificate.ridibooks-com.arn}"
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }
}
