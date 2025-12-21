# AWS Region Configuration
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for blue-green deployment"
}

# Network Configuration
variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for VPC"
}

variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "Availability zones for multi-AZ deployment"
}

# Instance Configuration
variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type (free tier eligible)"
}

variable "key_name" {
  type        = string
  default     = ""
  description = "EC2 Key Pair name for SSH access (optional)"
}

# Auto Scaling Configuration
variable "min_size" {
  type        = number
  default     = 1
  description = "Minimum number of instances in Auto Scaling Group"
}

variable "max_size" {
  type        = number
  default     = 4
  description = "Maximum number of instances in Auto Scaling Group"
}

variable "desired_capacity" {
  type        = number
  default     = 2
  description = "Desired number of instances in Auto Scaling Group"
}

# Blue-Green Deployment Configuration
variable "active_environment" {
  type        = string
  default     = "blue"
  description = "Currently active environment (blue or green)"
  
  validation {
    condition     = contains(["blue", "green"], var.active_environment)
    error_message = "Active environment must be either 'blue' or 'green'."
  }
}

variable "blue_version" {
  type        = string
  default     = "v1.0.0"
  description = "Version deployed in blue environment"
}

variable "green_version" {
  type        = string
  default     = "v1.1.0"
  description = "Version deployed in green environment"
}

# Health Check Configuration
variable "health_check_path" {
  type        = string
  default     = "/health"
  description = "Path for load balancer health checks"
}
