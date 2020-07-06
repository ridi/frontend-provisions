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

resource "aws_route_table" "main-new" {
  vpc_id = aws_vpc.main-new.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-new.id
  }
}

resource "aws_security_group" "books-alb" {
  name   = "books_alb"
  vpc_id = aws_vpc.main-new.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
