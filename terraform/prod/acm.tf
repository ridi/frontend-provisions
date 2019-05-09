resource "aws_acm_certificate" "ridicdn-net" {
  provider          = "aws.virginia"
  domain_name       = "*.ridicdn.net"
  validation_method = "DNS"
}
