# VPC Module - Network Infrastructure for 2-Tier Architecture
# Creates VPC, subnets, internet gateway, NAT gateway, and routing

# VPC - Virtual Private Cloud
resource "aws_vpc" "vpc_2tier" {
  cidr_block           = var.vpc_cidr  # Fixed: was vpc-cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Public Subnet - For web servers (internet accessible)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc_2tier.id
  cidr_block              = var.public_subnet
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.environment}-public-subnet"
  }
}

# Private Subnets - For database servers (no direct internet access)
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet)
  vpc_id            = aws_vpc.vpc_2tier.id
  cidr_block        = var.private_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

# Internet Gateway - Provides internet access to public subnet
resource "aws_internet_gateway" "aws_internet_gateway" {
  vpc_id = aws_vpc.vpc_2tier.id
  
  tags = {
    Name = "${var.environment}-igw"
  }
}

# Public Route Table - Routes traffic to internet gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_2tier.id

  # Fixed: route must be a block, not an object
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_internet_gateway.id
  }
  
  tags = {
    Name = "${var.environment}-public-rt"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "public_ass" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "aws_eip" {
  domain = "vpc"
  
  tags = {
    Name = "${var.environment}-nat-eip"
  }
}

# NAT Gateway - Provides internet access to private subnets
resource "aws_nat_gateway" "aws_nat_gateway" {
  subnet_id     = aws_subnet.public_subnet.id
  allocation_id = aws_eip.aws_eip.id

  depends_on = [aws_internet_gateway.aws_internet_gateway]
  
  tags = {
    Name = "${var.environment}-nat-gw"
  }
}

# Private Route Table - Routes traffic to NAT gateway
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_2tier.id

  # Fixed: route must be a block, not an object
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aws_nat_gateway.id
  }
  
  tags = {
    Name = "${var.environment}-private-rt"
  }
}

# Private Route Table Association - Associate all private subnets
resource "aws_route_table_association" "private_ass" {
  count          = length(aws_subnet.private_subnet)  # Fixed: proper count
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}