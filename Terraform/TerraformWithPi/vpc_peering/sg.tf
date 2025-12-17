resource "aws_security_group" "primary_sg" {
  name        = "primary-sg"
  description = "Security group for primary VPC"
  vpc_id      = aws_vpc.primery.id

  dynamic "ingress" {
    for_each = var.port
    content {
        from_port   = ingress.value
        to_port     = ingress.value
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }
  }

  ingress {
    description = "Allow ICMP from secondery VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.cidr["secondery"]]
  }

  ingress {
    description = "Allow all traffic from secondery VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.cidr["secondery"]]
  }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }   
    tags = {
        Name = "primary-sg"
    }
}

# Security group for secondary VPC - uses secondary provider
resource "aws_security_group" "secondery_sg" {
  provider = aws.secondary
  name        = "secondery-sg"
  description = "Security group for secondery VPC"
  vpc_id      = aws_vpc.secondery.id

  dynamic "ingress" {
    for_each = var.port
    content {
        from_port   = ingress.value
        to_port     = ingress.value
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }
  }

    ingress {
    description = "Allow ICMP from primary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.cidr["primary"]]
  }

    ingress {
    description = "Allow all traffic from primary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.cidr["primary"]]
  }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }   
    tags = {
        Name = "secondery-sg"
    }
}