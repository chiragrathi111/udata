# Create An Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "application-lb-tf"
  internal           = false
  load_balancer_type = "application"
  ip_address_type     = "ipv4"
  security_groups    = [aws_security_group.albb_sg.id]
  subnets            = [var.subnet_2a,var.subnet_2b]
# If yoy extra protection our load Balancerthen use 
 # enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

# Create a Target Group 
resource "aws_lb_target_group" "app" {
  name     = "application-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  tags = {
    Name = "cr-alb-tg"
  }
}
# Create Listener for ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
  tags = {
    Name = "cr-alb-listener"
  }
}