resource "aws_instance" "web_server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [var.web_security_group_id]
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = templatefile("${path.module}/templates/user_data.sh", {
    db_host     = var.db_host
    db_username = var.db_username
    db_password = var.db_password
    db_name     = var.db_name
  })

  tags = {
    Name = "${var.project_name}-web-server"
  }
}