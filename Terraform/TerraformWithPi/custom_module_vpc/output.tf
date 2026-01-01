# Root Module Outputs - Multiple VPCs
# These outputs display information about all VPCs created by the modules

# Development VPC Outputs
output "dev_vpc_id" {
  description = "ID of the Development VPC"
  value       = module.dev_vpc.vpc_id
}

output "dev_vpc_summary" {
  description = "Summary of Development VPC resources"
  value = {
    vpc_id              = module.dev_vpc.vpc_id
    vpc_cidr            = module.dev_vpc.vpc_cidr_block
    public_subnets      = length(module.dev_vpc.public_subnet_ids)
    private_subnets     = length(module.dev_vpc.private_subnet_ids)
  }
}

# Staging VPC Outputs
output "staging_vpc_id" {
  description = "ID of the Staging VPC"
  value       = module.staging_vpc.vpc_id
}

output "staging_vpc_summary" {
  description = "Summary of Staging VPC resources"
  value = {
    vpc_id              = module.staging_vpc.vpc_id
    vpc_cidr            = module.staging_vpc.vpc_cidr_block
    public_subnets      = length(module.staging_vpc.public_subnet_ids)
    private_subnets     = length(module.staging_vpc.private_subnet_ids)
  }
}

# Production VPC Outputs
output "prod_vpc_id" {
  description = "ID of the Production VPC"
  value       = module.prod_vpc.vpc_id
}

output "prod_vpc_summary" {
  description = "Summary of Production VPC resources"
  value = {
    vpc_id              = module.prod_vpc.vpc_id
    vpc_cidr            = module.prod_vpc.vpc_cidr_block
    public_subnets      = length(module.prod_vpc.public_subnet_ids)
    private_subnets     = length(module.prod_vpc.private_subnet_ids)
  }
}

# Testing VPC Outputs
output "test_vpc_id" {
  description = "ID of the Testing VPC"
  value       = module.test_vpc.vpc_id
}

output "test_vpc_summary" {
  description = "Summary of Testing VPC resources"
  value = {
    vpc_id              = module.test_vpc.vpc_id
    vpc_cidr            = module.test_vpc.vpc_cidr_block
    public_subnets      = length(module.test_vpc.public_subnet_ids)
    private_subnets     = length(module.test_vpc.private_subnet_ids)
  }
}

# All VPCs Summary
output "all_vpcs_summary" {
  description = "Summary of all VPCs created"
  value = {
    total_vpcs = 4
    vpcs = {
      development = module.dev_vpc.vpc_id
      staging     = module.staging_vpc.vpc_id
      production  = module.prod_vpc.vpc_id
      testing     = module.test_vpc.vpc_id
    }
  }
}