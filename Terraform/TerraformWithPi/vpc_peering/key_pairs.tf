# Create Key Pairs for EC2 instances
# Key pairs are required for SSH access to EC2 instances

# Generate TLS private key for primary region
resource "tls_private_key" "primary_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair in primary region using the generated public key
resource "aws_key_pair" "primary_key_pair" {
  key_name   = "MyPriKeyPair"
  public_key = tls_private_key.primary_key.public_key_openssh

  tags = {
    Name = "Primary-Key-Pair"
    Region = var.region["primary"]
  }
}

# Save private key to local file for SSH access
resource "local_file" "primary_private_key" {
  content  = tls_private_key.primary_key.private_key_pem
  filename = "${path.module}/primary-key.pem"  # Changed filename to avoid conflicts
  file_permission = "0600"  # Read-write for owner only
}

# Generate TLS private key for secondary region
resource "tls_private_key" "secondary_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair in secondary region using the generated public key
resource "aws_key_pair" "secondary_key_pair" {
  provider   = aws.secondary  # Important: Use secondary provider for us-west-2
  key_name   = "MySecKeyPair"
  public_key = tls_private_key.secondary_key.public_key_openssh

  tags = {
    Name = "Secondary-Key-Pair"
    Region = var.region["secondery"]
  }
}

# Save private key to local file for SSH access
resource "local_file" "secondary_private_key" {
  content  = tls_private_key.secondary_key.private_key_pem
  filename = "${path.module}/secondary-key.pem"  # Changed filename to avoid conflicts
  file_permission = "0600"  # Read-write for owner only
}

# Output key pair information for verification
output "key_pairs_info" {
  description = "Information about created key pairs and SSH commands"
  value = {
    primary = {
      key_name = aws_key_pair.primary_key_pair.key_name
      region   = var.region["primary"]
      file     = "${path.module}/primary-key.pem"
      ssh_command = "ssh -i ${path.module}/primary-key.pem ubuntu@${aws_instance.primary_instance.public_ip}"
    }
    secondary = {
      key_name = aws_key_pair.secondary_key_pair.key_name
      region   = var.region["secondery"]
      file     = "${path.module}/secondary-key.pem"
      ssh_command = "ssh -i ${path.module}/secondary-key.pem ubuntu@${aws_instance.secondery_instance.public_ip}"
    }
  }
}