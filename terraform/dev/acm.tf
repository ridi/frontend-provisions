resource "aws_acm_certificate" "ridi-io" {
  provider          = "aws.virginia"
  domain_name       = "*.ridi.io"
  validation_method = "DNS"
}
