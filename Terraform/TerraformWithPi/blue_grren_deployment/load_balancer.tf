# Application Load Balancer for Blue-Green Deployment
# This is the key component that switches traffic between blue and green environments

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "blue-green-alb"
  internal           = false  # Internet-facing load balancer
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = aws_subnet.public[*].id  # Deploy in public subnets

  # Enable deletion protection in production
  enable_deletion_protection = false

  tags = {
    Name = "blue-green-alb"
    Purpose = "Blue-Green Traffic Management"
  }
}

# Target Group for Blue Environment
resource "aws_lb_target_group" "blue" {
  name     = "blue-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  # Health check configuration
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "blue-target-group"
    Environment = "Blue"
  }
}

# Target Group for Green Environment
resource "aws_lb_target_group" "green" {
  name     = "green-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  # Health check configuration (same as blue)
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "green-target-group"
    Environment = "Green"
  }
}

# Load Balancer Listener
# This determines which target group receives traffic (blue or green)
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  # Default action - routes to active environment
  # Change target_group_arn to switch between blue and green
  default_action {
    type             = "forward"
    target_group_arn = var.active_environment == "blue" ? aws_lb_target_group.blue.arn : aws_lb_target_group.green.arn
  }

  tags = {
    Name = "blue-green-listener"
  }
}

# Optional: Listener rule for testing new environment
# This allows you to test the inactive environment using a specific path
resource "aws_lb_listener_rule" "test_environment" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = var.active_environment == "blue" ? aws_lb_target_group.green.arn : aws_lb_target_group.blue.arn
  }

  condition {
    path_pattern {
      values = ["/test/*"]  # Access inactive environment via /test/* path
    }
  }

  tags = {
    Name = "test-environment-rule"
  }
}