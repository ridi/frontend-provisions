resource "aws_acm_certificate" "ridibooks-com" {
  provider          = aws.virginia
  domain_name       = "*.ridibooks.com"
  validation_method = "DNS"
}

resource "aws_acm_certificate" "ridicdn-net" {
  provider          = aws.virginia
  domain_name       = "*.ridicdn.net"
  validation_method = "DNS"
}

resource "aws_acm_certificate" "ridi-com" {
  provider          = aws.virginia
  domain_name       = "*.ridi.com"
  validation_method = "DNS"
}
