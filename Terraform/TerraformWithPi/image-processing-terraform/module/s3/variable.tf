# =============================================================================
# S3 MODULE VARIABLES
# =============================================================================

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "bucket_purpose" {
  description = "Purpose of the bucket (upload or processed)"
  type        = string
  default     = "general"
}

variable "lambda_arn" {
  description = "ARN of the Lambda function to trigger (null if no trigger needed)"
  type        = string
  default     = null
}

variable "lambda_permission" {
  description = "Lambda permission resource for dependency"
  type        = any
  default     = null
}

variable "tags" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
  default     = {}
}
