resource "aws_instance" "ec2-vp1" {
  ami           = data.aws_ami.ami_vpc1.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet_vpc1.id
  vpc_security_group_ids = [aws_security_group.sg_vpc1.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.tls_vpc1_key.key_name  # Use created key pair

  depends_on = [ aws_key_pair.tls_vpc1_key ]

  tags = {
    Name = "EC2-VPC1"
  }
}

resource "aws_instance" "ec2-vp2" {
  provider = aws.vpc2
  ami           = data.aws_ami.ami_vpc2.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet_vpc2.id
  vpc_security_group_ids = [aws_security_group.sg_vpc2.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.tls_vpc2_key.key_name  # Use created key pair

  depends_on = [ aws_key_pair.tls_vpc2_key ]

  tags = {
    Name = "EC2-VPC2"
  }
}

resource "aws_instance" "ec2-vp3" {
  provider = aws.vpc3
  ami           = data.aws_ami.ami_vpc3.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet_vpc3.id
  vpc_security_group_ids = [aws_security_group.sg_vpc3.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.tls_vpc3_key.key_name  # Use created key pair

  depends_on = [ aws_key_pair.tls_vpc3_key ]

  tags = {
    Name = "EC2-VPC3"
  }
}