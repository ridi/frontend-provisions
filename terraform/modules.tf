module "dev" {
  source = "./dev/"

  providers = {
    aws = "aws.dev"
    aws.virginia = "aws.dev.virginia"
  }
}

module "prod" {
  source = "./prod/"

  providers = {
    aws = "aws.prod"
    aws.virginia = "aws.prod.virginia"
  }
}
