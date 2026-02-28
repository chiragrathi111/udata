# =============================================================================
# OUTPUTS - Security Group Information
# =============================================================================

output "security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.k8s_cluster_sg.id
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.k8s_cluster_sg.name
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.k8s_cluster_sg.arn
}

output "vpc_id" {
  description = "VPC ID where security group is created"
  value       = aws_security_group.k8s_cluster_sg.vpc_id
}
