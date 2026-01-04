# Security Groups Module Variables

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "2tier-app"
}

variable "port" {
  description = "List of ports for web server (HTTP, HTTPS, SSH)"
  type        = list(number)
  default     = [80, 443, 22]
}

variable "db_port" {
  description = "Database port (MySQL/MariaDB: 3306, PostgreSQL: 5432)"
  type        = number
  default     = 3306
}