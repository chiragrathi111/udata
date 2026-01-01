# Root Module Variables
# These variables are used to configure multiple VPCs

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Base name of the project for resource tagging"
  type        = string
  default     = "multi-vpc"
}