# Outputs for Blue-Green Deployment
# These provide important information about the deployed infrastructure

# Load Balancer Information
output "load_balancer_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.main.dns_name}"
}

output "test_url" {
  description = "URL to test the inactive environment"
  value       = "http://${aws_lb.main.dns_name}/test/"
}

# Environment Information
output "active_environment" {
  description = "Currently active environment receiving traffic"
  value       = var.active_environment
}

output "blue_environment_info" {
  description = "Information about blue environment"
  value = {
    version           = var.blue_version
    target_group_arn  = aws_lb_target_group.blue.arn
    asg_name         = aws_autoscaling_group.blue.name
    current_capacity = aws_autoscaling_group.blue.desired_capacity
  }
}

output "green_environment_info" {
  description = "Information about green environment"
  value = {
    version           = var.green_version
    target_group_arn  = aws_lb_target_group.green.arn
    asg_name         = aws_autoscaling_group.green.name
    current_capacity = aws_autoscaling_group.green.desired_capacity
  }
}

# Network Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

# Deployment Instructions
output "deployment_instructions" {
  description = "Instructions for blue-green deployment"
  value = {
    current_setup = "Active: ${var.active_environment} (${var.active_environment == "blue" ? var.blue_version : var.green_version})"
    switch_command = "To switch environments, change 'active_environment' variable to '${var.active_environment == "blue" ? "green" : "blue"}' and run 'terraform apply'"
    test_inactive = "Test inactive environment at: http://${aws_lb.main.dns_name}/test/"
  }
}