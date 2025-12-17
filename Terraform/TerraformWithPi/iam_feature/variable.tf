variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for IAM resources"
}

# Password policy settings
variable "password_policy" {
  type = object({
    minimum_password_length        = number
    require_lowercase_characters   = bool
    require_uppercase_characters   = bool
    require_numbers               = bool
    require_symbols               = bool
    allow_users_to_change_password = bool
    max_password_age              = number
    password_reuse_prevention     = number
  })
  default = {
    minimum_password_length        = 8
    require_lowercase_characters   = true
    require_uppercase_characters   = true
    require_numbers               = true
    require_symbols               = true
    allow_users_to_change_password = true
    max_password_age              = 90
    password_reuse_prevention     = 5
  }
  description = "Password policy configuration for IAM users"
}

# MFA settings
# variable "enforce_mfa" {
#   type        = bool
#   default     = true
#   description = "Whether to enforce MFA for all users"
# }
