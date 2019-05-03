module "dev" {
  source = "./dev/"

  providers = {
    aws = "aws.dev"
    aws.virginia = "aws.virginia"
  }
}

module "prod" {
  source = "./prod/"

  providers = {
    aws = "aws.prod"
  }
}
