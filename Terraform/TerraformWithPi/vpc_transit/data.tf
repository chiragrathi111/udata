data "aws_availability_zones" "vpc1_available" {
  state    = "available"
}

data "aws_availability_zones" "vpc2_available" {
  provider = aws.vpc2
  state    = "available"
}

data "aws_availability_zones" "vpc3_available" {
  provider = aws.vpc3
  state    = "available"
}

data "aws_ami" "ami_vpc1" {
  most_recent = true
  owners      = ["099720109477"]

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

data "aws_ami" "ami_vpc2" {
    provider = aws.vpc2
  most_recent = true
  owners      = ["099720109477"]

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

data "aws_ami" "ami_vpc3" {
    provider = aws.vpc3
  most_recent = true
  owners      = ["099720109477"]

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