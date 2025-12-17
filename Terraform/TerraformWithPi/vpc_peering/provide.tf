terraform {
  required_version = "~> 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    # TLS provider for generating SSH key pairs
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    # Local provider for saving files
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Primary provider for us-east-1
provider "aws" {
  alias  = "primary"
  region = var.region["primary"]
}

# Secondary provider for us-west-2 (required for cross-region VPC peering)
provider "aws" {
  alias  = "secondary"
  region = var.region["secondery"]
}

# Default provider (uses primary region)
provider "aws" {
  region = var.region["primary"]
}