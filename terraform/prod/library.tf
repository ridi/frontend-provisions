locals {
  library_s3_origin_id = "library-s3-origin"
}

resource "aws_s3_bucket" "library" {
  bucket = "ridi-library-prod"

  website {
    index_document = "index.html"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://library.ridibooks.com"]
  }
}

resource "aws_s3_bucket_policy" "library" {
  bucket = "${aws_s3_bucket.library.id}"
  policy = "${data.aws_iam_policy_document.library.json}"
}

data "aws_iam_policy_document" "library" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.library.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "library" {}

resource "aws_cloudfront_distribution" "library-ridicdn-net" {
  origin {
    domain_name = "${aws_s3_bucket.library.bucket_regional_domain_name}"
    origin_id   = "${local.library_s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.library.cloudfront_access_identity_path}"
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["library.ridicdn.net"]

  default_cache_behavior {
    allowed_methods = ["HEAD", "GET"]
    cached_methods  = ["HEAD", "GET"]
    compress        = false

    target_origin_id = "${local.library_s3_origin_id}"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

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
    acm_certificate_arn      = "${aws_acm_certificate.ridicdn-net.arn}"
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }
}
