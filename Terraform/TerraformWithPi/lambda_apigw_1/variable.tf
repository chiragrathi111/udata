variable "region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "lambda-api"

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 30
    error_message = "Project name must be between 1 and 30 characters."
  }
}

variable "api_stage_name" {
  description = "API Gateway deployment stage name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.api_stage_name)
    error_message = "Stage name must be one of: dev, staging, prod."
  }
}
