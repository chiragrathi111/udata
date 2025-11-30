variable "access_key" {
    type    = string
    default = null
    description = "Optional: AWS access key. Prefer using environment variables or shared credentials file instead of supplying this."
}

variable "secret_key" {
    type    = string
    default = null
    description = "Optional: AWS secret key. Prefer environment variables / shared credentials."
}

variable "region" {
    type    = string
    default = "us-east-1"
    description = "AWS Region (defaults to us-east-1)."
}

variable "ami_id" {
    type    = string
    default = null
    description = "Optional AMI ID. If not provided, the module will use the latest Amazon Linux 2 image in the chosen region."
}

variable "instance_type" {
    type    = string
    default = "t3.micro"
}

variable "port" {
    type    = list(number)
    default = [80]
    description = "List of ports used for web ingress (e.g., [80,443])"
}

variable "port1" {
    type    = list(number)
    default = [4000]
    description = "List of ports used for app ingress (e.g., [4000])"
}

variable "key_name" {
    type    = string
    default = "crrt"
    description = "Optional EC2 key pair name. If null the template will not assign a key pair."
}