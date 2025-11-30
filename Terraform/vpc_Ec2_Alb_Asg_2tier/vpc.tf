# Create a VPC
resource "aws_vpc" "chirag_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "chirag_vpc"
  }
}

# Create 4 Subnet 2 public and 2 private
resource "aws_subnet" "public_cr1" {
  vpc_id     = aws_vpc.chirag_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true  # FIXED: Auto-assign public IP for instances

  tags = {
    Name = "public_cr1a"
  }
}

resource "aws_subnet" "public_cr2" {
  vpc_id     = aws_vpc.chirag_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true  # FIXED: Auto-assign public IP for instances

  tags = {
    Name = "public_cr2"
  }
}

resource "aws_subnet" "private_cr1" {
  vpc_id     = aws_vpc.chirag_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private_cr1b"
  }
}

resource "aws_subnet" "private_cr2" {
  vpc_id     = aws_vpc.chirag_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private_cr2"
  }
}

# Create an Internat Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.chirag_vpc.id

  tags = {
    Name = "igw"
  }
}

# # Create 1 Elastic IP
# resource "aws_eip" "eip1" {
#   domain = "vpc"
# }

# # Create 1 NAT Gateway
# resource "aws_nat_gateway" "nat_gw1" {
#   allocation_id = aws_eip.eip1.id  
#   subnet_id     = aws_subnet.public_cr1.id

#   tags = {
#     Name = "nat-gw1"
#   }
# }

# Create a Public Route Table 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.chirag_vpc.id

  route {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.igw.id  
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Associate the Route Table with Public Subnets
resource "aws_route_table_association" "public_subnet1" {
  subnet_id      = aws_subnet.public_cr1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet2" {
  subnet_id      = aws_subnet.public_cr2.id
  route_table_id = aws_route_table.public_rt.id
}

# Create 2 Private Route Table
resource "aws_route_table" "private_rt1" {
    vpc_id = aws_vpc.chirag_vpc.id

    # route {
    #     cidr_block = "0.0.0.0/0"
    #     nat_gateway_id = aws_nat_gateway.nat_gw1.id
    # }
    tags = {
    Name = "Private Route Table 1"
  }
}

# Associate the Route Table with Private Subnets
resource "aws_route_table_association" "privateApp1" {
  subnet_id      = aws_subnet.private_cr1.id 
  route_table_id = aws_route_table.private_rt1.id
}

resource "aws_route_table_association" "privateApp2" {
  subnet_id      = aws_subnet.private_cr2.id 
  route_table_id = aws_route_table.private_rt1.id
}
