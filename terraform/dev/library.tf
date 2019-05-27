locals {
  library_hostname     = "library.ridi.io"
  library_s3_origin_id = "library-s3-origin"
}

resource "aws_s3_bucket" "library" {
  bucket = "ridi-library-dev"
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
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.library.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.library.arn}"]

    principals {
      type        = "AWS"
      identifiers = [
        "${aws_cloudfront_origin_access_identity.library.iam_arn}",
        "arn:aws:iam::268847686663:user/s3-deploy"
      ]
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "library" {}

resource "aws_cloudfront_distribution" "library-ridi-io" {
  origin {
    domain_name = "${aws_s3_bucket.library.bucket_regional_domain_name}"
    origin_id   = "${local.library_s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.library.cloudfront_access_identity_path}"
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["${local.library_hostname}"]

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

    target_origin_id = "${local.library_s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  default_root_object = "index.html"

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate.ridi-io.arn}"
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }

  web_acl_id = "${module.common.in_office_waf_acl_id}"
}
