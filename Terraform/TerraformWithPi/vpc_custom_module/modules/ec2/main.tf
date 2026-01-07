resource "aws_instance" "this" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name = var.key_name

  user_data = templatefile("${path.module}/templates/userdata.sh", {})
  
  tags = var.tags
}