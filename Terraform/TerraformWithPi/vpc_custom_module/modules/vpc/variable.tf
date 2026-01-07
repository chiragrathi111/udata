variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
  default = "10.8.8.0/24"
}

variable "az" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

