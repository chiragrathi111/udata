# Terraform configuration block
terraform {
  required_version = "~> 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Default AWS provider - IAM is global but we specify region for consistency
provider "aws" {
  region = var.region
  
  # Optional: Add default tags for all resources
  default_tags {
    tags = {
      Environment = "production"
      Project     = "iam-management"
      ManagedBy   = "terraform"
    }
  }
}