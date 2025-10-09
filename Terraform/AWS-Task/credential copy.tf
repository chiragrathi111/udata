terraform {
  required_version = "~> 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

#If I want our infra. getting a pdf then what is linking so run below command then download pdf file
#terraform graph | dot -Tpdf > graph.pdf
