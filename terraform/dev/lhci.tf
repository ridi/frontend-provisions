resource "aws_s3_bucket" "lhci" {
  bucket = "lhci"
}

resource "aws_s3_bucket_object" "lhci" {
  bucket = "${aws_s3_bucket.lhci.id}"
  key    = "beanstalk/lhci-eb.zip"
  source = "lhci-eb.zip"
}

resource "aws_elastic_beanstalk_application" "lhci" {
  name        = "lhci"
  description = "Google Lighthouse CI EB"
}

resource "aws_elastic_beanstalk_application_version" "lhci" {
  application = "lhci"
  bucket      = "${aws_s3_bucket.lhci.id}"
  key         = "${aws_s3_bucket_object.lhci.id}"
  name        = "lhci"
  description = "Google Lighthouse CI EB Version"
}

resource "aws_elastic_beanstalk_environment" "lhci" {
  application         = "${aws_elastic_beanstalk_application.lhci.name}"
  description         = "Google Lighthouse CI EB Env"
  cname_prefix        = "ridi-lhci"
  tier                = "WebServer"
  name                = "Lhci-env"
  solution_stack_name = "64bit Amazon Linux 2 v5.0.2 running Node.js 12"
  setting {
    name      = "aws:ec2:vpc"
    namespace = "VPCId"
    value     = "vpc-92b742f9"
  }
  setting {
    name      = "aws:ec2:vpc"
    namespace = "Subnets"
    value     = "subnet-f84f04b4"
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

