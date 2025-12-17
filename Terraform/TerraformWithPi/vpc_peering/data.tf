# data "aws_availability_zone" "primary" {
#     provider = aws.primary
#     name     = "${var.region["primary"]}a"
  
# }

data "aws_availability_zones" "primary_available" {
  state = "available"
}

# Availability zones for secondary region - uses secondary provider
data "aws_availability_zones" "secondary_available" {
  provider = aws.secondary
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# AMI data source for primary region - removed invalid 'region' attribute
# Data sources inherit region from provider configuration
data "aws_ami" "primary_ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

# AMI data source for secondary region - uses secondary provider
data "aws_ami" "secondery_ubuntu" {
  provider = aws.secondary
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
