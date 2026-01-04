# Root Module - 2-Tier Architecture
# This creates a complete 2-tier web application infrastructure

# SSM Module - Manages secrets and parameters
module "ssm" {
  source = "./module/ssm"

  environment = var.environment
  db_username = var.db_username
}

# VPC Module - Creates network infrastructure
module "vpc" {
  source = "./module/vpc"

  environment    = var.environment
  vpc_cidr       = var.vpc_cidr  # Fixed: was vpc-cidr
  public_subnet  = var.public_subnet
  private_subnet = var.private_subnet
}

# Security Groups Module - Creates security groups for web and database
module "sg" {
  source = "./module/sg"

  vpc_id       = module.vpc.vpc_id  # Added: SG needs VPC ID
  project_name = var.project_name   # Added: for naming
  port         = var.port
  db_port      = var.db_port
}

# RDS Module - Creates database infrastructure
module "rds" {
  source = "./module/rds"

  project_name         = var.project_name
  environment          = var.environment
  private_subnet_ids   = module.vpc.private_subnet_ids
  db_security_group_id = module.sg.db_sg_id  # Fixed: was module.security_groups
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = module.ssm.db_password  # Fixed: was module.secrets
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  engine_version       = var.db_engine_version
}

# EC2 Module - Creates web server infrastructure
module "ec2" {
  source = "./module/ec2"

  project_name          = var.project_name
  environment           = var.environment
  instance_type         = var.ec2_instance_type
  public_subnet_id      = module.vpc.public_subnet_id
  web_security_group_id = module.sg.web_sg_id  # Fixed: was module.security_groups
  db_host               = module.rds.db_endpoint
  db_username           = var.db_username
  db_password           = module.ssm.db_password  # Fixed: was module.secrets
  db_name               = var.db_name
}