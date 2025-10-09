/*
# Create S3 Bucket
resource "aws_s3_bucket" "s3" {
  bucket = "chirat123"

  tags = {
    Name        = "chirat123"
  }
}

# Disable Bucket versioning
resource "aws_s3_bucket_versioning" "versioning_s3" {
    bucket = aws_s3_bucket.s3.id
    versioning_configuration {
        status = "Disabled"
    }
}

# Block_public_policy
resource "aws_s3_bucket_public_access_block" "s3" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create an IAM Role
resource "aws_iam_role" "iam_role" {
  name = "ec2-s3-3tier"

  # Trust policy that allows EC2 
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AmazonS3ReadOnlyAccess Policy
resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Attach AmazonSSMManagedInstanceCore Policy
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create a VPC
resource "aws_vpc" "vpc3tier" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc3tier"
  }
}

# Create 6 Subnet 2 public and 4 private
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
resource "aws_subnet" "privateApp1" {
  vpc_id     = aws_vpc.vpc3tier.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "privateApp1"
  }
}
resource "aws_subnet" "privateApp2" {
  vpc_id     = aws_vpc.vpc3tier.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "privateApp2"
  }
}
resource "aws_subnet" "db1" {
  vpc_id     = aws_vpc.vpc3tier.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "db1"
  }
}
resource "aws_subnet" "db2" {
  vpc_id     = aws_vpc.vpc3tier.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "db2"
  }
}

# Create an Internat Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc3tier.id

  tags = {
    Name = "igw"
  }
}

# Create 2 Elastic IP
resource "aws_eip" "eip1" {
  domain = "vpc"
}
resource "aws_eip" "eip2" {
  domain = "vpc"
}

# Create 2 NAT Gateway
resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.eip1.id  
  subnet_id     = aws_subnet.publicWeb1.id

  tags = {
    Name = "nat-gw1"
  }
}
resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.eip2.id  
  subnet_id     = aws_subnet.publicWeb2.id

  tags = {
    Name = "nat-gw2"
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

# Create 2 Private Route Table
resource "aws_route_table" "private_rt1" {
    vpc_id = aws_vpc.vpc3tier.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gw1.id
    }
    tags = {
    Name = "Private Route Table 1"
  }
}

resource "aws_route_table" "private_rt2" {
    vpc_id = aws_vpc.vpc3tier.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gw2.id
    }
    tags = {
    Name = "Private Route Table 2"
  }
}

# Associate the Route Table with Private Subnets
resource "aws_route_table_association" "privateApp1" {
  subnet_id      = aws_subnet.privateApp1.id 
  route_table_id = aws_route_table.private_rt1.id
}

resource "aws_route_table_association" "privateApp2" {
  subnet_id      = aws_subnet.privateApp2.id 
  route_table_id = aws_route_table.private_rt2.id
}

# Create 5 Security Groups
resource "aws_security_group" "exlb_sg" {
  name        = "exlb_sg"
  description = "Security group for Ex. Load Balancer allowing HTTP from anywhere"
  vpc_id      = aws_vpc.vpc3tier.id 

  # Inbound rule for HTTP (IPv4)
  ingress {
    description      = "Allow HTTP from anywhere (IPv4)"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  
  }

  # Inbound rule for HTTP (IPv6)
  ingress {
    description      = "Allow HTTP from anywhere (IPv6)"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]  
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
    Name = "exlb-sg"
  }
}

# Web-SG security group allowing HTTP traffic from ExLB-SG security group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security group for Web instances"
  vpc_id      = aws_vpc.vpc3tier.id 

  # Outbound rule: Allow all outbound traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# Add security group rule to Web-SG to allow traffic from ExLB-SG
resource "aws_security_group_rule" "web_sg_from_exlb_sg" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web_sg.id
  source_security_group_id = aws_security_group.exlb_sg.id
}

# InLB-SG security group allowing HTTP traffic from Web-SG security group
resource "aws_security_group" "inlb_sg" {
  name        = "inlb_sg"
  description = "Security group for Internal Load Balancer instances"
  vpc_id      = aws_vpc.vpc3tier.id 

  # Outbound rule: Allow all outbound traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "inlb-sg"
  }
}

# Add security group rule to InLB-SG to allow traffic from Web-SG
resource "aws_security_group_rule" "inlb-sg_from_web_sg" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.inlb_sg.id
  source_security_group_id = aws_security_group.web_sg.id
}

# App-SG security group allowing HTTP traffic from InLB-SG security group
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Security group for App instances"
  vpc_id      = aws_vpc.vpc3tier.id 

  # Outbound rule: Allow all outbound traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "App-SG"
  }
}

# Add security group rule to App-SG to allow traffic from In-LB-SG
resource "aws_security_group_rule" "app_sg_from_inlb_sg" {
  type                     = "ingress"
  from_port                = 4000
  to_port                  = 4000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app_sg.id
  source_security_group_id = aws_security_group.inlb_sg.id
}

# DB-SG security group
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Security group for DB allowing MYSQL from anywhere"
  vpc_id      = aws_vpc.vpc3tier.id 

  # Outbound rule: Allow all outbound traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "DB-SG"
  }
}

# Add security group rule to DB-SG to allow traffic from App-SG
resource "aws_security_group_rule" "db_sg_from_app_sg" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_sg.id
  source_security_group_id = aws_security_group.app_sg.id
}

# Create an IAM Instance Profile
resource "aws_iam_instance_profile" "iam_profile" {
  name = "ec2-s3-3tier-profile"
  role = aws_iam_role.iam_role.name
}

# Create A Web Ec2 Instance
resource "aws_instance" "webs" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.publicWeb1.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Attach IAM instance profile
  iam_instance_profile  = aws_iam_instance_profile.iam_profile.name

  #Added User Data
  user_data     = <<-EOF
    #!/bin/bash
    sudo apt-get upgrade -y
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl enable apache2
    sudo chmod 777 /var/www
    sudo chmod 777 /var/www/html/index.html
    echo "Hello World CHIRAG RATHI  OM from $(hostname -f)" > /var/www/html/index.html
EOF

  tags = {
    Name = "Web Server 1"
  }
}

# Create Instance ami
resource "aws_ami_from_instance" "exapi" {
  name               = "instance-ami"
  source_instance_id = aws_instance.webs.id
}

# Create a Target Group 
resource "aws_lb_target_group" "exlb_tg" {
  name     = "external-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc3tier.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
}

}

# Target Group Attach
#resource "aws_lb_target_group_attachment" "exlb_tg_attach" {
# target_group_arn = aws_lb_target_group.exlb_tg.arn
# target_id        = aws_instance.webs.id
#port             = 80
#}

# Create An External Elastic Load Balancer
resource "aws_lb" "ex_lb" {
  name               = "external-lb-tf"
  internal           = false
  load_balancer_type = "application"
  ip_address_type     = "ipv4"
  security_groups    = [aws_security_group.exlb_sg.id]
  subnets            = [
    aws_subnet.publicWeb1.id,
    aws_subnet.publicWeb2.id
  ]
# If yoy extra protection our load Balancerthen use 
 # enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

# Create Listener for ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ex_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.exlb_tg.arn
  }
}

# Create an External Launch Template
resource "aws_launch_template" "ex_launch_template" {
  name_prefix   = "external-launch-template"
  image_id      = aws_ami_from_instance.exapi.id
  instance_type = "t2.micro"
}

# Create A External Auto Scaling
resource "aws_autoscaling_group" "ex_asg" {
  name  = "external-autoscaling-Group"
  vpc_zone_identifier = [
    aws_subnet.publicWeb1.id,
    aws_subnet.publicWeb2.id
  ]
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2
  health_check_grace_period = 300
  health_check_type = "ELB"
  target_group_arns    = [aws_lb_target_group.exlb_tg.arn]
  force_delete       = true
  termination_policies = ["OldestInstance", "Default"]

  launch_template {
    id      = aws_launch_template.ex_launch_template.id
    version = "$Latest"
  }

  tag {
  key                 = "Environment"
  value               = "External Production"
  propagate_at_launch = true
}
}

# Create A App Ec2 Instance
resource "aws_instance" "apps" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.privateApp1.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # Attach IAM instance profile
  iam_instance_profile  = aws_iam_instance_profile.iam_profile.name

  #Added User Data
  user_data     = <<-EOF
    #!/bin/bash
    sudo apt-get upgrade -y
    sudo apt update -y
    sudo apt install apache2 -y
    sudo sed -i 's/Listen 80/Listen 4000/' /etc/apache2/ports.conf
    sudo sed -i 's/:80/:4000/g' /etc/apache2/sites-enabled/000-default.conf
    sudo systemctl restart apache2
    sudo systemctl enable apache2
    sudo chmod 777 /var/www
    sudo chmod 777 /var/www/html/index.html
    echo "Hello World CHIRAG RATHI  OM from $(hostname -f)" > /var/www/html/index.html
EOF

  tags = {
    Name = "App Server 1"
  }
}

# Create Instance ami
resource "aws_ami_from_instance" "inapi" {
  name               = "internal-ami"
  source_instance_id = aws_instance.apps.id
}

# Create a Target Group 
resource "aws_lb_target_group" "inlb_tg" {
  name     = "internal-lb-tg"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc3tier.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "4000"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
}

}

# Target Group Attach
#resource "aws_lb_target_group_attachment" "inlb_tg_attach" {
# target_group_arn = aws_lb_target_group.inlb_tg.arn
# target_id        = aws_instance.apps.id
#port             = 4000
#}

# Create An Internal Elastic Load Balancer
resource "aws_lb" "in_lb" {
  name               = "internals-lb-tf"
  internal           = true
  load_balancer_type = "application"
  ip_address_type     = "ipv4"
  security_groups    = [aws_security_group.inlb_sg.id]
  subnets            = [
    aws_subnet.privateApp1.id,
    aws_subnet.privateApp2.id
  ]
# If yoy extra protection our load Balancerthen use 
 # enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

# Create Listener for ALB
resource "aws_lb_listener" "http1" {
  load_balancer_arn = aws_lb.in_lb.arn
  port              = "4000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.inlb_tg.arn
  }
}

# Create an Internal Launch Template
resource "aws_launch_template" "in_launch_template" {
  name_prefix   = "internal-launch-template"
  image_id      = aws_ami_from_instance.inapi.id
  instance_type = "t2.micro"
}

# Create A Internal Auto Scaling
resource "aws_autoscaling_group" "in_asg" {
  name  = "internal-autoscaling-Group"
  vpc_zone_identifier = [
    aws_subnet.privateApp1.id,
    aws_subnet.privateApp2.id
  ]
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2
  health_check_grace_period = 300
  health_check_type = "ELB"
  target_group_arns    = [aws_lb_target_group.inlb_tg.arn]
  force_delete       = true
  termination_policies = ["OldestInstance", "Default"]

  launch_template {
    id      = aws_launch_template.in_launch_template.id
    version = "$Latest"
  }

  tag {
  key                 = "Environment"
  value               = "internal Production"
  propagate_at_launch = true
}
}

# Create a Subnet Group
resource "aws_db_subnet_group" "db_group" {
  name       = "aws_db_subnet_group"
  subnet_ids = [aws_subnet.db1.id, aws_subnet.db2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

# Create A RDS Database
resource "aws_db_instance" "mydb" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = "db.t4g.micro"
  storage_type         = "gp2"
  identifier           = "mydb"
  username             = "admin"
  password             = "Admin123"
  db_subnet_group_name = aws_db_subnet_group.db_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot  = true

  tags = {
        Name = "MyRDSDB"
  }
}
*/