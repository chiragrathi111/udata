# Create A Internal Auto Scaling
resource "aws_autoscaling_group" "in_asg" {
  name  = "internal-autoscaling-Group"
  vpc_zone_identifier = [var.subnet_2a,var.subnet_2b]
  
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1
  target_group_arns    = [aws_lb_target_group.app.arn]

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
  health_check_type = "EC2"
}

output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}