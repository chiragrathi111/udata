# Local values for Blue-Green Deployment
# These are computed values used throughout the configuration

locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = "blue-green-deployment"
    ManagedBy   = "terraform"
    Environment = "production"
  }

  # Environment-specific tags
  blue_tags = merge(local.common_tags, {
    Environment = "blue"
    Version     = var.blue_version
  })

  green_tags = merge(local.common_tags, {
    Environment = "green"
    Version     = var.green_version
  })

  # Determine which environment is active/inactive
  active_target_group_arn = var.active_environment == "blue" ? aws_lb_target_group.blue.arn : aws_lb_target_group.green.arn
  inactive_target_group_arn = var.active_environment == "blue" ? aws_lb_target_group.green.arn : aws_lb_target_group.blue.arn

  # Environment versions
  active_version = var.active_environment == "blue" ? var.blue_version : var.green_version
  inactive_version = var.active_environment == "blue" ? var.green_version : var.blue_version

  # Subnet calculations
  public_subnet_cidrs = [
    for i in range(length(var.availability_zones)) : cidrsubnet(var.vpc_cidr, 8, i + 1)
  ]

  private_subnet_cidrs = [
    for i in range(length(var.availability_zones)) : cidrsubnet(var.vpc_cidr, 8, i + 10)
  ]
}