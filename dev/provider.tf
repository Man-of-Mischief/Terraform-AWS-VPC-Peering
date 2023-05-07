################# provider.tf
provider "aws" {
  region     = var.az
  access_key = var.access_key
  secret_key = var.secret_key


  default_tags {
    tags = {
      "project" = var.project
      "env"     = var.env
    }
  }
}
