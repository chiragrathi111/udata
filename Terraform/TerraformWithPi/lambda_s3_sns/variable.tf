variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "s3-email-notifier"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "email" {
  description = "Email address for SNS notifications"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.email))
    error_message = "Must be valid email address."
  }
}