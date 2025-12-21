resource "tls_private_key" "tls_vpc1_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tls_vpc1_key" {
  key_name   = "tls_vpc1_key"
  public_key = tls_private_key.tls_vpc1_key.public_key_openssh
  tags = {
    Name = "tls_vpc1_key"
  }
}

resource "local_file" "local_vpc1_key" {
  content  = tls_private_key.tls_vpc1_key.private_key_pem
  filename = "${path.module}/tls_vpc1_key.pem"
  file_permission = "0600"
}

resource "tls_private_key" "tls_vpc2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tls_vpc2_key" {
  provider   = aws.vpc2
  key_name   = "tls_vpc2_key"
  public_key = tls_private_key.tls_vpc2_key.public_key_openssh
  tags = {
    Name = "tls_vpc2_key"
  } 
}

resource "local_file" "local_vpc2_key" {
  content  = tls_private_key.tls_vpc2_key.private_key_pem
  filename = "${path.module}/tls_vpc2_key.pem"
  file_permission = "0600"
}

resource "tls_private_key" "tls_vpc3_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tls_vpc3_key" {
  provider   = aws.vpc3
  key_name   = "tls_vpc3_key"
  public_key = tls_private_key.tls_vpc3_key.public_key_openssh
  tags = {
    Name = "tls_vpc3_key"
  } 
}

resource "local_file" "local_vpc3_key" {
  content  = tls_private_key.tls_vpc3_key.private_key_pem
  filename = "${path.module}/tls_vpc3_key.pem"
  file_permission = "0600"
}