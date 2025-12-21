# Auto Scaling Groups for Blue-Green Deployment
# These manage the EC2 instances in each environment

# Data source to get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Launch Template for Blue Environment
resource "aws_launch_template" "blue" {
  name_prefix   = "blue-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.ec2.id]

  # User data script to configure the instance
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = "blue"
    app_version = var.blue_version
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "blue-instance"
      Environment = "Blue"
      Version = var.blue_version
    }
  }

  tags = {
    Name = "blue-launch-template"
    Environment = "Blue"
  }
}

# Launch Template for Green Environment
resource "aws_launch_template" "green" {
  name_prefix   = "green-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.ec2.id]

  # User data script to configure the instance
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = "green"
    app_version = var.green_version
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "green-instance"
      Environment = "Green"
      Version = var.green_version
    }
  }

  tags = {
    Name = "green-launch-template"
    Environment = "Green"
  }
}

# Auto Scaling Group for Blue Environment
resource "aws_autoscaling_group" "blue" {
  name                = "blue-asg"
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.blue.arn]
  health_check_type   = "ELB"  # Use load balancer health checks
  health_check_grace_period = 300

  min_size         = var.active_environment == "blue" ? var.min_size : 0
  max_size         = var.max_size
  desired_capacity = var.active_environment == "blue" ? var.desired_capacity : 0

  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }

  # Instance refresh configuration for rolling updates
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "blue-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Environment"
    value               = "Blue"
    propagate_at_launch = true
  }
}

# Auto Scaling Group for Green Environment
resource "aws_autoscaling_group" "green" {
  name                = "green-asg"
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.green.arn]
  health_check_type   = "ELB"  # Use load balancer health checks
  health_check_grace_period = 300

  min_size         = var.active_environment == "green" ? var.min_size : 0
  max_size         = var.max_size
  desired_capacity = var.active_environment == "green" ? var.desired_capacity : 0

  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }

  # Instance refresh configuration for rolling updates
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "green-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Environment"
    value               = "Green"
    propagate_at_launch = true
  }
}

# Auto Scaling Policies for Blue Environment
resource "aws_autoscaling_policy" "blue_scale_up" {
  name                   = "blue-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.blue.name
}

resource "aws_autoscaling_policy" "blue_scale_down" {
  name                   = "blue-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.blue.name
}

# Auto Scaling Policies for Green Environment
resource "aws_autoscaling_policy" "green_scale_up" {
  name                   = "green-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.green.name
}

resource "aws_autoscaling_policy" "green_scale_down" {
  name                   = "green-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.green.name
}