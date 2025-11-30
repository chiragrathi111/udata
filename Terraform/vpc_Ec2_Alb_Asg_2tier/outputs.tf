# Output the ALB DNS names for easy access
output "web_alb_dns_name" {
  description = "DNS name of the external ALB - Access your web application here"
  value       = aws_lb.ex_alb.dns_name
}

output "web_alb_url" {
  description = "Full URL to access your web application"
  value       = "http://${aws_lb.ex_alb.dns_name}"
}

output "app_alb_dns_name" {
  description = "DNS name of the internal ALB (for internal communication)"
  value       = aws_lb.in_alb.dns_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.chirag_vpc.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [aws_subnet.public_cr1.id, aws_subnet.public_cr2.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [aws_subnet.private_cr1.id, aws_subnet.private_cr2.id]
}