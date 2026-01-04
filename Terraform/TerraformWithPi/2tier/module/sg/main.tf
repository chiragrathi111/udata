# Security Groups Module - Web and Database Security Groups
# Creates security groups for 2-tier architecture

# Web Security Group - Allows HTTP/HTTPS traffic from internet
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id  # Added: SG needs VPC ID

  # Dynamic ingress rules for multiple ports (80, 443, 22)
  dynamic "ingress" {
    for_each = var.port
    content {
      from_port   = ingress.value  # Fixed: was each.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Egress rules - Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# Database Security Group - Allows traffic only from web servers
resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for database servers"
  vpc_id      = var.vpc_id  # Added: SG needs VPC ID

  # Ingress rule - Allow database port from web security group only
  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]  # Only from web SG
  }

  # Egress rules - Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}