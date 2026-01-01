# Root Module - Main Terraform configuration that uses the VPC module
# This file calls the child module multiple times to create multiple VPCs

# Data source to get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC 1 - Development Environment
# Creates a VPC for development with smaller CIDR
module "dev_vpc" {
  source = "./module"

  # Development VPC configuration
  vpc_cidr        = "10.0.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  project_name    = "${var.project_name}-dev"
}

# VPC 2 - Staging Environment
# Creates a VPC for staging with different CIDR
module "staging_vpc" {
  source = "./module"

  # Staging VPC configuration
  vpc_cidr        = "10.1.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  private_subnets = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]
  project_name    = "${var.project_name}-staging"
}

# VPC 3 - Production Environment
# Creates a VPC for production with different CIDR
module "prod_vpc" {
  source = "./module"

  # Production VPC configuration
  vpc_cidr        = "10.2.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  private_subnets = ["10.2.11.0/24", "10.2.12.0/24", "10.2.13.0/24"]
  project_name    = "${var.project_name}-prod"
}

# VPC 4 - Testing Environment (Optional)
# Creates a smaller VPC for testing
module "test_vpc" {
  source = "./module"

  # Testing VPC configuration (smaller network)
  vpc_cidr        = "10.3.0.0/24"
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)  # Only 2 AZs
  public_subnets  = ["10.3.0.0/26", "10.3.0.64/26"]                        # Smaller subnets
  private_subnets = ["10.3.0.128/26", "10.3.0.192/26"]                     # Smaller subnets
  project_name    = "${var.project_name}-test"
}