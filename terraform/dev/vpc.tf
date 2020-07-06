locals {
  subnets = {
    "ap-northeast-2a" = "172.31.0.0/20"
    "ap-northeast-2b" = "172.31.16.0/20"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "ap-northeast-2a" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "172.31.0.0/20"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "ap-northeast-2b" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "172.31.32.0/20"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "ap-northeast-2c" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "172.31.16.0/20"
  map_public_ip_on_launch = true
}

resource "aws_vpc" "main-new" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "main-new" {
  for_each                = local.subnets
  vpc_id                  = aws_vpc.main-new.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_internet_gateway" "main-new" {
  vpc_id = aws_vpc.main-new.id
}
