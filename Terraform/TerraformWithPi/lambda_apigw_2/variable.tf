variable "region" {
  description = "AWS region for resources"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "api_stage_name" {
  description = "API Gateway stage name (dev, prod, etc.)"
  type        = string
}