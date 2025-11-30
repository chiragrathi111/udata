# Create A External Auto Scaling
resource "aws_autoscaling_group" "ex_asg" {
  name  = "external-autoscaling-Group"
  vpc_zone_identifier = [
    aws_subnet.public_cr1.id,
    aws_subnet.public_cr2.id
  ]
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1
  health_check_grace_period = 300
  health_check_type = "ELB"
  target_group_arns    = [aws_lb_target_group.ex_alb_tg.arn]
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
  
  # FIXED: Added Name tag for better instance identification
  tag {
    key                 = "Name"
    value               = "Web-Server"
    propagate_at_launch = true
  }
}


# Create A Internal Auto Scaling
resource "aws_autoscaling_group" "in_asg" {
  name  = "internal-autoscaling-Group"
  vpc_zone_identifier = [
    aws_subnet.private_cr1.id,
    aws_subnet.private_cr2.id
  ]
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1
  health_check_grace_period = 300
  health_check_type = "ELB"
  target_group_arns    = [aws_lb_target_group.in_alb_tg.arn]
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
  
  # FIXED: Added Name tag for better instance identification
  tag {
    key                 = "Name"
    value               = "App-Server"
    propagate_at_launch = true
  }
}