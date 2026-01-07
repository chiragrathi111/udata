variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "ami_id" {
  type = string
}

variable "key_name" {
  type = string
  default = "vpc2"
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "tags" {
  type = map(string)
}