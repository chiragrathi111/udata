# Terraform configuration for Blue-Green Deployment
terraform {
  required_version = "~> 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.region
  
  # Default tags applied to all resources
  default_tags {
    tags = {
      Project     = "blue-green-deployment"
      ManagedBy   = "terraform"
      Environment = "production"
    }
  }
}