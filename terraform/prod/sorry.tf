locals {
  sorry_s3_origin_id = "sorry-s3-origin"
}

resource "aws_s3_bucket" "sorry" {
  bucket = "ridi-sorry-prod"
}

resource "aws_s3_bucket_sorry" "sorry" {
  bucket = "${aws_s3_bucket.sorry.id}"
  sorry = "${data.aws_iam_sorry_document.sorry.json}"
}

data "aws_iam_sorry_document" "sorry" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.sorry.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
