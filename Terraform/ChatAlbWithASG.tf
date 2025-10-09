# Create a VPC
resource "aws_vpc" "vpc3tier" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc3tier"
  }
}

# Create 2 public
resource "aws_subnet" "publicWeb1" {
  vpc_id     = aws_vpc.vpc3tier.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "publicWeb1"
  }
}
resource "aws_subnet" "publicWeb2" {
  vpc_id     = aws_vpc.vpc3tier.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "publicWeb2"
  }
}

# Create an Internat Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc3tier.id

  tags = {
    Name = "igw"
  }
}

# Create a Public Route Table 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc3tier.id

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
  subnet_id      = aws_subnet.publicWeb1.id 
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet2" {
  subnet_id      = aws_subnet.publicWeb2.id 
  route_table_id = aws_route_table.public_rt.id
}

# Security Group for ALB (allow HTTP from anywhere)
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTP traffic from anywhere"
  vpc_id   = aws_vpc.vpc3tier.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for EC2 (allow HTTP traffic only from ALB)
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow HTTP traffic from ALB"
  vpc_id   = aws_vpc.vpc3tier.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Allow traffic only from ALB SG
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic only from ALB SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch Template for EC2 in ASG
resource "aws_launch_template" "my_launch_template" {
  name_prefix   = "my-launch-template-"
  image_id      = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  # key_name      = "chirag.pem"  # Your PEM file

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]  # Attach EC2 security group

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Server1"
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo apt-get upgrade -y
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl enable apache2
    sudo chmod 777 /var/www
    sudo chmod 777 /var/www/html/index.html
    echo "Hello World CHIRAG RATHI OM from $(hostname -f)" > /var/www/html/index.html
EOF
  )
}

# ALB (Internet-facing)
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.publicWeb1.id,aws_subnet.publicWeb2.id]  # Replace with your subnet IDs

  enable_deletion_protection = false
  ip_address_type            = "ipv4"
  idle_timeout               = 60
}

# Target Group for ALB
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc3tier.id  # Replace with your VPC ID

  health_check {
    protocol = "HTTP"
    path     = "/"
    interval = 30
  }
}

# Listener for ALB (direct traffic to target group)
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}

# Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "my_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.publicWeb1.id,aws_subnet.publicWeb2.id]  # Replace with your subnets
  target_group_arns    = [aws_lb_target_group.my_target_group.arn]

  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
  lb_target_group_arn    = aws_lb_target_group.my_target_group.arn
}
