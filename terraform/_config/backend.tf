terraform {

  backend "s3" {
    bucket = ""
    key    = ""
    region = ""

    use_lockfile = true

    assume_role = {
      role_arn = ""
    }
  }
}
