# Output useful information about created resources

# List all created users with their departments
output "created_users" {
  description = "List of all created IAM users with their departments"
  value = {
    for user_key, user in aws_iam_user.user : user_key => {
      username   = user.name
      department = user.tags["Department"]
      role       = user.tags["Role"]
      arn        = user.arn
    }
  }
}

# Show group memberships for verification
output "group_memberships" {
  description = "Users assigned to each group"
  value = {
    education = aws_iam_group_membership.education_members.users
    sales     = aws_iam_group_membership.sales_members.users
    corporate = aws_iam_group_membership.corporate_members.users
    managers  = aws_iam_group_membership.managers_members.users
  }
}

# # MFA device information
# output "mfa_devices" {
#   description = "Virtual MFA devices created for users"
#   value = {
#     for user_key, mfa in aws_iam_virtual_mfa_device.user_mfa : user_key => {
#       device_name = mfa.virtual_mfa_device_name
#       arn         = mfa.arn
#       qr_code_png = mfa.qr_code_png
#     }
#   }
#   sensitive = true  # QR codes contain sensitive data
# }

# Account information
output "account_info" {
  description = "AWS Account information"
  value = {
    account_id = data.aws_caller_identity.account.account_id
    user_id    = data.aws_caller_identity.account.user_id
  }
}