output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.this.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "route_table_id" {
  description = "ID of the route table"
  value       = aws_route_table.this.id
}

# Output is very important, if you want to use the child module id like vpc_id, subnet_id etc in parent module so first define output in child module
#  and then call that output in parent module.
# Then only you can use that child module resource in parent module.