resource "aws_acm_certificate" "ridi-io" {
  provider          = aws.virginia
  domain_name       = "*.ridi.io"
  validation_method = "DNS"
}

resource "aws_acm_certificate" "paper-ridi-io" {
  provider          = aws.virginia
  domain_name       = "*.paper.ridi.io"
  validation_method = "DNS"
}
