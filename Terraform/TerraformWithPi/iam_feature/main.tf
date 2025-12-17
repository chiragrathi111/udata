# Create IAM users from CSV data
# Each user gets a unique name based on first_name + last_name
resource "aws_iam_user" "user" {
  for_each = { for user in local.users : user.first_name => user }
  name     = lower("${each.value.first_name}_${each.value.last_name}")
  path     = "/users/"

  # Tags help with group assignment and organization
  tags = {
    Department = each.value.department
    Role       = each.value.job_title
    CreatedBy  = "Terraform"
    MFARequired = "true"
  }
}

# Create login profiles (passwords) for each user
# Users must change password on first login for security
resource "aws_iam_user_login_profile" "user_login" {
  for_each = aws_iam_user.user
  user     = each.value.name
  
  # Generate strong random password (8 characters minimum)
  password_length         = 8
  password_reset_required = true
  
  # Uncomment below if you have PGP keys for encryption
  # pgp_key = "keybase:your_keybase_username"

  lifecycle {
    # Ignore changes to avoid recreating passwords unnecessarily
    ignore_changes = [password_reset_required, password_length]
  }
}

# # Create virtual MFA devices for each user
# # Users will need to set these up for account access
# resource "aws_iam_virtual_mfa_device" "user_mfa" {
#   for_each         = aws_iam_user.user
#   virtual_mfa_device_name = each.value.name
#   path            = "/mfa/"
  
#   tags = {
#     User = each.value.name
#     Department = each.value.tags["Department"]
#   }
# }

# Create access keys for programmatic access (optional)
# Uncomment if users need CLI/API access
# resource "aws_iam_access_key" "user_access_key" {
#   for_each = aws_iam_user.user
#   user     = each.value.name
#   
#   # Uncomment if you have PGP key for encryption
#   # pgp_key = "keybase:your_keybase_username"
# }