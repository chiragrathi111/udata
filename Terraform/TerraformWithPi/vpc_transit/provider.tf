terraform {
  required_version = "~> 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

  tls = {
    source  = "hashicorp/tls"
    version = "~> 4.0"
  }

  }
}

# Primary provider for us-east-1
provider "aws" {
  alias  = "vpc1"
  region = var.region["region_vpc1"]
}

provider "aws" {
  alias = "vpc2"
  region = var.region["region_vpc2"]
}

provider "aws" {
  alias = "vpc3"
  region = var.region["region_vpc3"]
}

provider "aws" {
  region = var.region["region_vpc1"]
}