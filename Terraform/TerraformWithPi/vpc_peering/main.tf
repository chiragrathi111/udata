# VPC for primary region - removed invalid 'region' attribute
# VPCs inherit region from the provider configuration
resource "aws_vpc" "primery" {
  cidr_block = var.cidr["primary"]
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_names["primary"]
  }
}

resource "aws_subnet" "primary" {
  vpc_id            = aws_vpc.primery.id
  cidr_block        = cidrsubnet(var.cidr["primary"], 8, 1)
  availability_zone = data.aws_availability_zones.primary_available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = var.aws_subnet["primary"]
  }
  
}

resource "aws_internet_gateway" "primary" {
  vpc_id = aws_vpc.primery.id

  tags = {
    Name = "primary-igw"
  }
}

resource "aws_route_table" "primary" {
    vpc_id = aws_vpc.primery.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.primary.id
    }
}

resource "aws_route_table_association" "primary" {
    subnet_id      = aws_subnet.primary.id
    route_table_id = aws_route_table.primary.id
}

# VPC for secondary region - uses secondary provider alias
# This ensures the VPC is created in the correct region (us-west-2)
resource "aws_vpc" "secondery" {
  provider = aws.secondary
  cidr_block = var.cidr["secondery"]
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_names["secondery"]
  }
}

# Subnet in secondary region - uses secondary provider
resource "aws_subnet" "secondery" {
  provider = aws.secondary
  vpc_id            = aws_vpc.secondery.id
  cidr_block        = cidrsubnet(var.cidr["secondery"], 8, 1)
  availability_zone = data.aws_availability_zones.secondary_available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = var.aws_subnet["secondery"]
  }
}

# Internet Gateway in secondary region
resource "aws_internet_gateway" "secondery" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondery.id

  tags = {
    Name = "secondery-igw"
  }
}

# Route table in secondary region
resource "aws_route_table" "secondery" {
    provider = aws.secondary
    vpc_id = aws_vpc.secondery.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.secondery.id
    }
}

# Route table association in secondary region
resource "aws_route_table_association" "secondery" {
  provider = aws.secondary
  subnet_id = aws_subnet.secondery.id
  route_table_id = aws_route_table.secondery.id
}

resource "aws_vpc_peering_connection" "primary_to_secondery" {
  vpc_id        = aws_vpc.primery.id
  peer_vpc_id   = aws_vpc.secondery.id
  peer_region   = var.region["secondery"]
  auto_accept   = false

  tags = {
    Name = "primary-to-secondery"
  }
}

# VPC peering connection accepter - must use secondary provider
# This accepts the peering connection in the secondary region
resource "aws_vpc_peering_connection_accepter" "secondery" {
    provider = aws.secondary
    vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondery.id
    auto_accept               = true
}

resource "aws_route" "primary_to_secondery" {
  route_table_id         = aws_route_table.primary.id
  destination_cidr_block = var.cidr["secondery"]
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondery.id

  depends_on = [ aws_vpc_peering_connection_accepter.secondery ]
}

# Route from secondary to primary VPC - uses secondary provider
resource "aws_route" "secondery_to_primary" {
  provider = aws.secondary
  route_table_id         = aws_route_table.secondery.id
  destination_cidr_block = var.cidr["primary"]
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondery.id

  depends_on = [ aws_vpc_peering_connection_accepter.secondery ]
}