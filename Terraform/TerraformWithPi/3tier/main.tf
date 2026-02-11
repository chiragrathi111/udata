data "aws_caller_identity" "current" {}

resource "random_password" "dbPassword" {
  length = 16
  special = true
  override_special = "@#$%^&*()_+={}[]|:;<>?,./"
}

