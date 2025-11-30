resource "aws_security_group" "web_alb_cr_sg" {
  name        = "chirag_rathi_alb_sg"
  vpc_id      = aws_vpc.chirag_vpc.id
  description = "Security group for web ALB"

  # FIXED: Only allow HTTP/HTTPS for ALB, not SSH
  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "cr_alb_sg"
  }
}

resource "aws_security_group" "web_ec2_cr_sg" {
  name = "chirag_rathi_ec2_sg"
  vpc_id = aws_vpc.chirag_vpc.id
  description = "Security group for web servers"

  # FIXED: Allow HTTP from ALB
  ingress {
    description     = "Allow HTTP from Web ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_alb_cr_sg.id]
  }
  
  # FIXED: Allow HTTPS from ALB
  ingress {
    description     = "Allow HTTPS from Web ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.web_alb_cr_sg.id]
  }
  
  # FIXED: Allow SSH from anywhere for troubleshooting
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "cr_ec2_sg"
  }   
}

resource "aws_security_group" "app_alb_cr_sg" {
  name        = "chirag_rathi_app_alb_sg"
  vpc_id      = aws_vpc.chirag_vpc.id
  description = "Security group for app ALB"

  # FIXED: Allow port 4000 from Web EC2 instances
  ingress {
    description     = "Allow port 4000 from Web EC2"
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.web_ec2_cr_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  tags = {
    Name = "cr_app_alb_sg"
  }
}

resource "aws_security_group" "app_ec2_cr_sg" {
  name = "chirag_rathi_app_ec2_sg"
  vpc_id = aws_vpc.chirag_vpc.id
  description = "Security group for app servers"

  # FIXED: Allow port 4000 from App ALB
  ingress {
    description     = "Allow port 4000 from App ALB"
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.app_alb_cr_sg.id]
  }
  
  # FIXED: Allow SSH from web tier for troubleshooting
  ingress {
    description     = "Allow SSH from Web EC2"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_ec2_cr_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  tags = {
    Name = "cr_app_ec2_sg"
  }
}
