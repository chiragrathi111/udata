# Child Module Outputs
# These outputs expose the created resources to the root module

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.module_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.module_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private_subnet[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.module_igw.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.module_rt_pub.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.module_rt_pri.id
}