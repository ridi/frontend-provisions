module "dev" {
  source = "./dev/"

  providers = {
    aws = "aws.dev"
  }
}

module "prod" {
  source = "./prod/"

  providers = {
    aws = "aws.prod"
  }
}
