terraform {
  required_version = ">=1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

# Access key & secret key come from terraform.tfvars (never hardcode!)
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
