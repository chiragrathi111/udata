resource "aws_security_group" "albb_sg" {
  name        = "albb_sg"
  description = "Security group for web"

  # Outbound rule: Allow
  dynamic "ingress" {
    for_each = var.port
    iterator = port
    content {
      description = "Allow Port ${port.value} from anywhere (IPv4)"  
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Outbound rule: Allow all outbound traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "alb_sg"
  }
}

resource "aws_security_group" "webb_sg" {
    name = "webb_sg"
    description = "web_sg"

    # Inbound rule for SSH (IPv4)
  ingress {
    description      = "Allow SSH from anywhere (IPv4)"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  
  }

  # Outbound rule: Allow all outbound traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Allow HTTP traffic from ALB SG to Web SG
resource "aws_security_group_rule" "webb_sg_from_albb_sg" {
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    security_group_id        = aws_security_group.webb_sg.id
    source_security_group_id = aws_security_group.albb_sg.id
}