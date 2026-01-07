# Production approach - Using data sources (RECOMMENDED)
# Commented out due to permission issues
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Fallback approach - Hardcoded values (for permission issues)
# Uncomment these if you don't have EC2 permissions
# locals {
#   ubuntu_ami_id = "ami-0e86e20dae9224db8"  # Ubuntu 22.04 LTS in us-east-1
#   availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
# }