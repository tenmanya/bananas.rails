variable "remote_state_s3_bucket" {
  type = string
}

variable "remote_state_s3_region" {
  type = string
}

data "terraform_remote_state" "meta" {
  backend = "s3"

  config = {
    bucket = var.remote_state_s3_bucket
    region = var.remote_state_s3_region
    key    = "meta.terraform/terraform.tfstate"
  }
}
