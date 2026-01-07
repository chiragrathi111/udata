variable "vpc_cidr-a" {
  type = string
}

variable "vpc_cidr-b" {
  type = string
}

variable "vpc_cidr-c" {
  type = string
}

variable "public_subnet_cidr-a" {
  type = string
}

variable "public_subnet_cidr-b" {
  type = string
}

variable "public_subnet_cidr-c" {
  type = string
}

variable "list_of_port" {
  type = list(number)
}

variable "region" {
  type = string
}