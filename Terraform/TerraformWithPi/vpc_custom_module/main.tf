module "vpc-a" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr-a
  public_subnet_cidr = var.public_subnet_cidr-a
  az = [data.aws_availability_zones.available.names[0]]  # Production approach
#   az = [local.availability_zones[0]]  # Fallback for permission issues
  tags = {
    Name = "vpc-a"
    Environment = "Dev"
  }
}

module "vpc-b" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr-b
  public_subnet_cidr = var.public_subnet_cidr-b
  az = [data.aws_availability_zones.available.names[0]]  # Production approach
#   az = [local.availability_zones[0]]  # Fallback for permission issues
  tags = {
    Name = "vpc-b"
    Environment = "Dev"
  }
}

module "vpc-c" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr-c
  public_subnet_cidr = var.public_subnet_cidr-c
  az = [data.aws_availability_zones.available.names[0]]  # Production approach
#   az = [local.availability_zones[0]]  # Fallback for permission issues
  tags = {
    Name = "vpc-c"
    Environment = "Prod"
  }
}

module "sg-a" {
  source = "./modules/sg"
  vpc_id = module.vpc-a.vpc_id
  port_no = var.list_of_port
}

module "sg-b" {
  source = "./modules/sg"
  vpc_id = module.vpc-b.vpc_id
  port_no = var.list_of_port
}

module "sg-c" {
  source = "./modules/sg"
  vpc_id = module.vpc-c.vpc_id
  port_no = var.list_of_port
}

module "ec2-a" {
  source = "./modules/ec2"

  subnet_id = module.vpc-a.subnet_id
  ami_id = data.aws_ami.ubuntu.id  # Production approach
#   ami_id = local.ubuntu_ami_id   # Fallback for permission issues
  security_group_id = module.sg-a.security_group_id

  tags = {
    Name = "ec2-a"
    Environment = "Dev"
  }
}

module "ec2-b" {
  source = "./modules/ec2"

  subnet_id = module.vpc-b.subnet_id
  ami_id = data.aws_ami.ubuntu.id  # Production approach
#   ami_id = local.ubuntu_ami_id   # Fallback for permission issues
  security_group_id = module.sg-b.security_group_id

  tags = {
    Name = "ec2-b"
    Environment = "Dev"
  }
}

module "ec2-c" {
  source = "./modules/ec2"

  subnet_id = module.vpc-c.subnet_id
  ami_id = data.aws_ami.ubuntu.id  # Production approach
#   ami_id = local.ubuntu_ami_id   # Fallback for permission issues
  security_group_id = module.sg-c.security_group_id

  tags = {
    Name = "ec2-c"
    Environment = "Prod"
  }
}