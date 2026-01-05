# =============================================================================
# SNS MODULE VARIABLES
# =============================================================================

variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "email" {
  description = "Email address for notifications"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.email))
    error_message = "Please provide a valid email address."
  }
}

variable "tags" {
  description = "Tags to apply to SNS resources"
  type        = map(string)
  default     = {}
}
