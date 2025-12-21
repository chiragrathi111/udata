variable "region" {
  type = map(string)
}

variable "cidr" {
  type = map(string)
}

variable "vpc" {
  type = map(string)
}

variable "subnet" {
  type = map(string)
}

variable "igw" {
  type = map(string)
}

variable "rt" {
  type = map(string)
}

variable "tgw_attachment" {
  type = map(string)
}

variable "port" {
  type = list(number)
}

variable "tags" {
  type = map(string)
}

variable "instance_type" {
  type = string
}


