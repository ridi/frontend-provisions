locals {
  policy_s3_origin_id = "policy-s3-origin"
}

resource "aws_s3_bucket" "policy" {
  bucket = "ridi-policy-prod"
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = "${aws_s3_bucket.policy.id}"
  policy = "${data.aws_iam_policy_document.policy.json}"
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.policy.arn}"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.policy.iam_arn]
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "policy" {}

resource "aws_cloudfront_distribution" "policy-ridi-com" {
  origin {
    domain_name = "${aws_s3_bucket.policy.bucket_regional_domain_name}"
    origin_id   = "${local.policy_s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.policy.cloudfront_access_identity_path}"
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["policy.ridicdn.net"]

  default_cache_behavior {
    allowed_methods = ["HEAD", "GET"]
    cached_methods  = ["HEAD", "GET"]
    compress        = false

    target_origin_id = "${local.policy_s3_origin_id}"

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
