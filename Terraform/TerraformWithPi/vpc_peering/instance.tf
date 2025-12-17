# EC2 instance in primary region - uses default provider (primary region)
resource "aws_instance" "primary_instance" {
  ami           = data.aws_ami.primary_ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.primary.id
  key_name = aws_key_pair.primary_key_pair.key_name  # Use created key pair
  vpc_security_group_ids = [aws_security_group.primary_sg.id]
  associate_public_ip_address = true  # Use this instead of public_ip

  # Ensure key pair is created before instance
  depends_on = [aws_key_pair.primary_key_pair]

  tags = {
    Name = "Primary-Instance"
  }
}

# EC2 instance in secondary region - uses secondary provider
resource "aws_instance" "secondery_instance" {
  provider = aws.secondary
  ami           = data.aws_ami.secondery_ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.secondery.id
  key_name = aws_key_pair.secondary_key_pair.key_name  # Use created key pair
  vpc_security_group_ids = [aws_security_group.secondery_sg.id]
  associate_public_ip_address = true  # Use this instead of public_ip

  # Ensure key pair is created before instance
  depends_on = [aws_key_pair.secondary_key_pair]

  tags = {
    Name = "Secondary-Instance"  # Fixed typo: Secondery -> Secondary
  }
}