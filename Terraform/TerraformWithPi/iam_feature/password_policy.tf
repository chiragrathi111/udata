# Account Password Policy - Enforces strong passwords for all IAM users
# This applies to the entire AWS account, not individual users

resource "aws_iam_account_password_policy" "strict_policy" {
  # Minimum password requirements
  minimum_password_length        = var.password_policy.minimum_password_length
  require_lowercase_characters   = var.password_policy.require_lowercase_characters
  require_uppercase_characters   = var.password_policy.require_uppercase_characters
  require_numbers               = var.password_policy.require_numbers
  require_symbols               = var.password_policy.require_symbols
  
  # User password management
  allow_users_to_change_password = var.password_policy.allow_users_to_change_password
  
  # Password rotation and reuse
  max_password_age              = var.password_policy.max_password_age
  password_reuse_prevention     = var.password_policy.password_reuse_prevention
  
  # Force password reset if compromised
  hard_expiry = false  # Set to true if you want to force password reset after max_password_age
}

# Output password policy details for verification
output "password_policy_summary" {
  description = "Summary of the applied password policy"
  value = {
    min_length = aws_iam_account_password_policy.strict_policy.minimum_password_length
    requires = {
      lowercase = aws_iam_account_password_policy.strict_policy.require_lowercase_characters
      uppercase = aws_iam_account_password_policy.strict_policy.require_uppercase_characters
      numbers   = aws_iam_account_password_policy.strict_policy.require_numbers
      symbols   = aws_iam_account_password_policy.strict_policy.require_symbols
    }
    max_age_days = aws_iam_account_password_policy.strict_policy.max_password_age
    reuse_prevention = aws_iam_account_password_policy.strict_policy.password_reuse_prevention
  }
}