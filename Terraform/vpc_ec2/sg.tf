resource "aws_security_group" "albb_sg" {
  name        = "chirag_rathi_sg"
  vpc_id      = aws_vpc.chirag_vpc.id
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
    Name = "cr_sg"
  }
}
