variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "environment" {
  type = string
}

variable "public_subnet" {
  type = string
}

variable "private_subnet" {
  type = list(string)
}

variable "port" {
  type = list(number)
}

variable "db_port" {
  type = number
}

# EC2 Variables
variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# RDS Variables
variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "webappdb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 10
}

variable "db_engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "project_name" {
  type = string
  default = "two_tier"
}