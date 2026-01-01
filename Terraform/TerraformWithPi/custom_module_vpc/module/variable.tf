# Child Module Variables
# These variables are received from the root module

variable "vpc_cidr" {  # Fixed: was "cidr"
  description = "CIDR block for VPC"
  type        = string
}

variable "project_name" {
  description = "Name of the project for resource tagging"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnets" {  # Fixed: was "public_subnet"
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {  # Fixed: was "private_subnet"
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}
