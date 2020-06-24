data "aws_elastic_beanstalk_solution_stack" "docker" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux (.*) Node.js (.*)$"
}

resource "aws_s3_bucket" "lhci" {
  bucket = "lhci"
}

resource "aws_s3_bucket_object" "lhci" {
  bucket = aws_s3_bucket.lhci.id
  key    = "beanstalk/lhci-eb.zip"
  source = "lhci-eb.zip"
}

resource "aws_elastic_beanstalk_application" "lhci" {
  name        = "lhci"
  description = "Google Lighthouse CI EB"
}

resource "aws_elastic_beanstalk_application_version" "lhci" {
  application = "lhci"
  bucket      = aws_s3_bucket.lhci.id
  key         = aws_s3_bucket_object.lhci.id
  name        = "lhci"
  description = "Google Lighthouse CI EB Version"
}

resource "aws_elastic_beanstalk_environment" "lhci" {
  application         = aws_elastic_beanstalk_application.lhci.name
  description         = "Google Lighthouse CI EB Env"
  cname_prefix        = "ridi-lhci"
  tier                = "WebServer"
  name                = "Lhci-env"
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.docker.name
  setting {
    name      = "aws:ec2:vpc"
    namespace = "VPCId"
    value     = aws_vpc.main.id
  }
  setting {
    name      = "aws:ec2:vpc"
    namespace = "Subnets"
    value     = aws_subnet.ap-northeast-2a.id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }
  // https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html#command-options-general-elasticbeanstalkmanagedactions
  setting {
    name      = "ManagedActionsEnabled"
    namespace = "aws:elasticbeanstalk:managedactions"
    value     = false
  }
}

