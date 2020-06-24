resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "ap-northeast-2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.0.0/20"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "ap-northeast-2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.32.0/20"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "ap-northeast-2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.16.0/20"
  map_public_ip_on_launch = true
}
