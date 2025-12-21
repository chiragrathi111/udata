resource "aws_vpc" "vpc1" {
  cidr_block = var.cidr["cidr_vpc1"]
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc["vpc1"]
  } 
}

resource "aws_subnet" "subnet_vpc1" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block       = cidrsubnet(var.cidr["cidr_vpc1"], 8, 1)
  availability_zone = data.aws_availability_zones.vpc1_available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet["subnet_vpc1"]
  }
}

resource "aws_internet_gateway" "igw_vpc1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = var.igw["igw_vpc1"]
  }
}

resource "aws_route_table" "rt_vpc1" {
    vpc_id = aws_vpc.vpc1.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc1.id
    }

    tags = {
      Name = var.rt["rt_vpc1"]
    }
}

resource "aws_route_table_association" "rt_ass_vpc1" {
  subnet_id      = aws_subnet.subnet_vpc1.id
  route_table_id = aws_route_table.rt_vpc1.id
}

resource "aws_vpc" "vpc2" {
  provider = aws.vpc2
  cidr_block = var.cidr["cidr_vpc2"]
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc["vpc2"]
  } 
}

resource "aws_subnet" "subnet_vpc2" {
  provider = aws.vpc2 
  vpc_id            = aws_vpc.vpc2.id
  cidr_block       = cidrsubnet(var.cidr["cidr_vpc2"], 8, 1)
  availability_zone = data.aws_availability_zones.vpc2_available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet["subnet_vpc2"]
  }
}

resource "aws_internet_gateway" "igw_vpc2" {
  provider = aws.vpc2
  vpc_id = aws_vpc.vpc2.id
  tags = {
    Name = var.igw["igw_vpc2"]
  }
}

resource "aws_route_table" "rt_vpc2" {
    provider = aws.vpc2
    vpc_id = aws_vpc.vpc2.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc2.id
    }

    tags = {
      Name = var.rt["rt_vpc2"]
    }
}

resource "aws_route_table_association" "rt_ass_vpc2" {
  provider = aws.vpc2
  subnet_id      = aws_subnet.subnet_vpc2.id
  route_table_id = aws_route_table.rt_vpc2.id
}

resource "aws_vpc" "vpc3" {
  provider = aws.vpc3
  cidr_block = var.cidr["cidr_vpc3"]
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc["vpc3"]
  }
}

resource "aws_subnet" "subnet_vpc3" {
  provider = aws.vpc3
  vpc_id            = aws_vpc.vpc3.id
  cidr_block       = cidrsubnet(var.cidr["cidr_vpc3"], 8, 1)
  availability_zone = data.aws_availability_zones.vpc3_available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet["subnet_vpc3"]
  }
}

resource "aws_internet_gateway" "igw_vpc3" {
  provider = aws.vpc3
  vpc_id = aws_vpc.vpc3.id
  tags = {
    Name = var.igw["igw_vpc3"]
  }
}

resource "aws_route_table" "rt_vpc3" {
    provider = aws.vpc3
    vpc_id = aws_vpc.vpc3.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc3.id
    }

    tags = {
      Name = var.rt["rt_vpc3"]
    }
}

resource "aws_route_table_association" "rt_ass_vpc3" {
  provider = aws.vpc3
  subnet_id      = aws_subnet.subnet_vpc3.id
  route_table_id = aws_route_table.rt_vpc3.id
}