# Create A Web Ec2 Instance
resource "aws_instance" "webs" {
  ami           = var.ami_id
  instance_type = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.albb_sg.id]
  key_name = aws_key_pair.deployer.key_name

  #Added User Data
  user_data     = file("${path.module}/userdata.sh")

  tags = {
    Name = "Web Server 1"
  }
}