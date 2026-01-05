# =============================================================================
# CLOUDWATCH MODULE VARIABLES
# =============================================================================

variable "lambda_function_name" {
  description = "Name of the Lambda function to monitor"
  type        = string
}

variable "critical_sns_arn" {
  description = "ARN of SNS topic for critical alerts"
  type        = string
}

variable "normal_sns_arn" {
  description = "ARN of SNS topic for normal notifications"
  type        = string
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "tags" {
  description = "Tags to apply to CloudWatch resources"
  type        = map(string)
  default     = {}
}
