# Create an External Launch Template
resource "aws_launch_template" "app_launch_template" {
  name   = "application-launch-template"
  image_id =  var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.webb_sg.id]
  }
  user_data = filebase64("userdata.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
        Name = "cr-web-server"
    }
  }
}