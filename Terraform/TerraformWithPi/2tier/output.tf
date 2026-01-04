output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = module.ec2.public_dns
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_endpoint
}

output "application_url" {
  description = "URL to access the web application"
  value       = "http://${module.ec2.public_ip}:8080"
}