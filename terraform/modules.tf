module "dev" {
  source = "./dev/"

  providers = {
    aws          = aws.dev
    aws.virginia = aws.dev_virginia
  }
}

module "prod" {
  source = "./prod/"

  providers = {
    aws          = aws.prod
    aws.virginia = aws.prod_virginia
  }
}
