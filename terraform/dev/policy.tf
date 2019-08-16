locals {
  policy_s3_origin_id = "policy-s3-origin"
}

resource "aws_s3_bucket" "policy" {
  bucket = "policy.ridi.io"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = "${aws_s3_bucket.policy.id}"
  policy = "${data.aws_iam_policy_document.policy.json}"
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.policy.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
