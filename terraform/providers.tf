variable "aws_dev_access_key" {}
variable "aws_dev_secret_key" {}
variable "aws_prod_access_key" {}
variable "aws_prod_secret_key" {}

variable "region" {
  default = "ap-northeast-2"
}

provider "aws" {
  alias      = "dev"
  access_key = var.aws_dev_access_key
  secret_key = var.aws_dev_secret_key
  region     = var.region
}

provider "aws" {
  alias      = "dev_virginia"
  access_key = var.aws_dev_access_key
  secret_key = var.aws_dev_secret_key
  region     = "us-east-1"
}

provider "aws" {
  alias      = "prod"
  access_key = var.aws_prod_access_key
  secret_key = var.aws_prod_secret_key
  region     = var.region
}

provider "aws" {
  alias      = "prod_virginia"
  access_key = var.aws_prod_access_key
  secret_key = var.aws_prod_secret_key
  region     = "us-east-1"
}
