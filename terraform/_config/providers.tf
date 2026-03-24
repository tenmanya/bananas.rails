provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      environment = var.environment
      service     = "bananas"
    }
  }

  assume_role {
    role_arn = "arn:aws:iam::205899621967:role/fullaccess"
  }
}

data "aws_region" "current" {}
