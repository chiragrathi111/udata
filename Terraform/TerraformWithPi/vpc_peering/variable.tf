variable "region" {
    type = map(string)
    default = {
        "primary" = "us-east-1"
        "secondery" = "us-west-2"
    }
}

variable "cidr" {
    type = map(string)
    default = {
        "primary" = "10.0.0.0/16"
        "secondery" = "192.68.0.0/16"
    }
}

variable "port" {
  type = list(number)
}

variable "vpc_names" {
    type = map(string)
    default = {
        "primary" = "primary-vpc"
        "secondery" = "secondery-vpc"
    }
}

variable "aws_subnet" {
    type = map(string)
    default = {
        "primary" = "primary-subnet"
        "secondery" = "secondery-subnet"
    }
}

# Instance type - t3.micro is free tier eligible and available in all regions
variable "instance_type" {
    type = string
    default = "t3.micro"  # Changed from t2.micro for better free tier compatibility
}

variable "key_name" {
  type = map(string)
}