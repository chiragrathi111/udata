# VPC Module Outputs

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc_2tier.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.vpc_2tier.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private_subnet[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.aws_internet_gateway.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.aws_nat_gateway.id
}