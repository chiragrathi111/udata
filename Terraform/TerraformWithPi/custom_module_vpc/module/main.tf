# Child Module - VPC Infrastructure Resources
# This module creates a complete VPC with public and private subnets

# VPC - Virtual Private Cloud
# Creates an isolated network environment in AWS
resource "aws_vpc" "module_vpc" {
  cidr_block           = var.vpc_cidr  # Fixed: was var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Public Subnets - Subnets with internet access
# These subnets can host resources that need internet connectivity
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnets)  # Fixed: was var.public_subnet
  vpc_id                  = aws_vpc.module_vpc.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.azs[count.index]

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"  # Fixed: removed extra }
  }
}

# Private Subnets - Subnets without direct internet access
# These subnets host resources that don't need direct internet connectivity
resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnets)  # Fixed: was var.private_subnet
  vpc_id                  = aws_vpc.module_vpc.id
  cidr_block              = var.private_subnets[count.index]
  map_public_ip_on_launch = false
  availability_zone       = var.azs[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  }
}

# Internet Gateway - Provides internet access to VPC
# Allows resources in public subnets to access the internet
resource "aws_internet_gateway" "module_igw" {  # Fixed: removed comma
  vpc_id = aws_vpc.module_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Route Table - Routes traffic to internet gateway
# Defines routing rules for public subnets
resource "aws_route_table" "module_rt_pub" {
  vpc_id = aws_vpc.module_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.module_igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Public Route Table Association - Associates public subnets with public route table
# Links each public subnet to the public route table
resource "aws_route_table_association" "rt_ass_pub" {
  count          = length(aws_subnet.public_subnet)  # Fixed: proper reference
  route_table_id = aws_route_table.module_rt_pub.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# Private Route Table - Routes traffic within VPC
# Defines routing rules for private subnets (no internet access)
resource "aws_route_table" "module_rt_pri" {
  vpc_id = aws_vpc.module_vpc.id

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Private Route Table Association - Associates private subnets with private route table
# Links each private subnet to the private route table
resource "aws_route_table_association" "rt_ass_pri" {
  count          = length(aws_subnet.private_subnet)  # Fixed: proper reference
  route_table_id = aws_route_table.module_rt_pri.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}