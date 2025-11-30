# Create a Target Group 
resource "aws_lb_target_group" "ex_alb_tg" {
  name     = "external-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.chirag_vpc.id

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

# Create An External Elastic Load Balancer
resource "aws_lb" "ex_alb" {
  name               = "external-alb-tf"
  internal           = false
  load_balancer_type = "application"
  ip_address_type     = "ipv4"
  security_groups    = [aws_security_group.web_alb_cr_sg.id]
  subnets            = [
    aws_subnet.public_cr1.id,
    aws_subnet.public_cr2.id
  ]
# If yoy extra protection our load Balancerthen use 
 # enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

# Create Listener for ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ex_alb.arn
  port              = "80"
  protocol          = "HTTP"

  # FIXED: Correct syntax for forward action
  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.ex_alb_tg.arn
      }
    }
  }
}

# Create a Target Group For Internal
resource "aws_lb_target_group" "in_alb_tg" {
  # AWS disallows names that begin with "internal-" for some resources; avoid that prefix
  name     = "alb-tg-internal"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.chirag_vpc.id

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

# Create An Internal Elastic Load Balancer
resource "aws_lb" "in_alb" {
  # name must not begin with "internal-"; use an allowed alternative
  name               = "alb-tf-internal"
  internal           = true
  load_balancer_type = "application"
  ip_address_type     = "ipv4"
  security_groups    = [aws_security_group.app_alb_cr_sg.id]
  subnets            = [
    aws_subnet.private_cr1.id,
    aws_subnet.private_cr2.id
  ]
# If yoy extra protection our load Balancerthen use 
 # enable_deletion_protection = true    

  tags = {
    Environment = "production"
  }
}

# Create Listener for Internal ALB
resource "aws_lb_listener" "in_http" {
  load_balancer_arn = aws_lb.in_alb.arn
  port              = "4000"
  protocol          = "HTTP"
  
  # FIXED: Correct syntax for forward action
  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.in_alb_tg.arn
      }
    }
  }
}