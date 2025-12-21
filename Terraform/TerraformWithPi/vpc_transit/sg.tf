resource "aws_security_group" "sg_vpc1" {
  name        = "sg_vpc1"
  description = "Security group for VPC1"
  vpc_id      = aws_vpc.vpc1.id

  # Allow SSH, HTTP, HTTPS from internet
  dynamic "ingress" {
    for_each = var.port
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Allow ICMP (ping) from all VPC CIDR blocks
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [
      var.cidr["cidr_vpc1"],
      var.cidr["cidr_vpc2"],
      var.cidr["cidr_vpc3"]
    ]
  }

  # Allow all TCP traffic from other VPCs
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [
      var.cidr["cidr_vpc2"],
      var.cidr["cidr_vpc3"]
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "sg-vpc1"
  }
}

resource "aws_security_group" "sg_vpc2" {
  provider    = aws.vpc2
  name        = "sg_vpc2"
  description = "Security group for VPC2"
  vpc_id      = aws_vpc.vpc2.id

  # Allow SSH, HTTP, HTTPS from internet
  dynamic "ingress" {
    for_each = var.port
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Allow ICMP (ping) from all VPC CIDR blocks
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [
      var.cidr["cidr_vpc1"],
      var.cidr["cidr_vpc2"],
      var.cidr["cidr_vpc3"]
    ]
  }

  # Allow all TCP traffic from other VPCs
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [
      var.cidr["cidr_vpc1"],
      var.cidr["cidr_vpc3"]
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "sg-vpc2"
  }
}

resource "aws_security_group" "sg_vpc3" {
  provider    = aws.vpc3
  name        = "sg_vpc3"
  description = "Security group for VPC3"
  vpc_id      = aws_vpc.vpc3.id

  # Allow SSH, HTTP, HTTPS from internet
  dynamic "ingress" {
    for_each = var.port
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Allow ICMP (ping) from all VPC CIDR blocks
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [
      var.cidr["cidr_vpc1"],
      var.cidr["cidr_vpc2"],
      var.cidr["cidr_vpc3"]
    ]
  }

  # Allow all TCP traffic from other VPCs
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [
      var.cidr["cidr_vpc1"],
      var.cidr["cidr_vpc2"]
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "sg-vpc3"
  }
}