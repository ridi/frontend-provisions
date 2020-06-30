resource "aws_ebs_volume" "lhci" {
  availability_zone = "ap-northeast-2c"
  size              = 1

  tags = {
    Name = "Lighthouse"
  }
}
