terraform {
  backend "remote" {
    organization = "ridi"

    workspaces = {
      name = "frontend"
    }
  }
}
