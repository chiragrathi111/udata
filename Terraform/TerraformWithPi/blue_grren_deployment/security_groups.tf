# Security Groups for Blue-Green Deployment
# These control network access to different components

# Security group for Application Load Balancer
# Allows HTTP and HTTPS traffic from internet
resource "aws_security_group" "alb" {
  name        = "blue-green-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP traffic from internet
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS traffic from internet
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "blue-green-alb-sg"
    Purpose = "Load Balancer Security"
  }
}

# Security group for EC2 instances (Blue and Green environments)
# Allows traffic only from load balancer and SSH access
resource "aws_security_group" "ec2" {
  name        = "blue-green-ec2-sg"
  description = "Security group for EC2 instances in blue-green deployment"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP traffic from load balancer only
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow application traffic from load balancer (port 8080 for Java apps)
  ingress {
    description     = "Application port from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow SSH access for management (restrict to your IP in production)
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change to your IP: ["YOUR_IP/32"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "blue-green-ec2-sg"
    Purpose = "EC2 Instance Security"
  }
}