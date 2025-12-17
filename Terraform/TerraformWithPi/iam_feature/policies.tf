# IAM Policies for different groups
# Each group gets specific permissions based on their role

# Education Group Policy - Read-only access to educational resources
resource "aws_iam_policy" "education_policy" {
  name        = "EducationPolicy"
  path        = "/policies/"
  description = "Policy for Education department - read-only access to training resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "ec2:DescribeInstances",
          "cloudformation:DescribeStacks"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = ["us-east-1", "us-west-2"]
          }
        }
      }
    ]
  })
}

# Sales Group Policy - Access to CRM and customer data
resource "aws_iam_policy" "sales_policy" {
  name        = "SalesPolicy"
  path        = "/policies/"
  description = "Policy for Sales department - access to customer data and CRM systems"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          "arn:aws:s3:::sales-*/*",
          "arn:aws:dynamodb:*:*:table/customers",
          "arn:aws:dynamodb:*:*:table/leads"
        ]
      }
    ]
  })
}

# Corporate Group Policy - Administrative access
resource "aws_iam_policy" "corporate_policy" {
  name        = "CorporatePolicy"
  path        = "/policies/"
  description = "Policy for Corporate executives - administrative access with restrictions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "s3:*",
          "iam:ListUsers",
          "iam:ListGroups",
          "iam:GetUser",
          "cloudformation:*",
          "cloudwatch:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "iam:DeleteUser",
          "iam:CreateUser",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

# Managers Group Policy - Team management and reporting access
resource "aws_iam_policy" "managers_policy" {
  name        = "ManagersPolicy"
  path        = "/policies/"
  description = "Policy for Managers - team oversight and reporting capabilities"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
          "iam:GenerateCredentialReport",
          "iam:GetCredentialReport"
        ]
        Resource = "*"
      }
    ]
  })
}

# # MFA Enforcement Policy - Applied to all users
# resource "aws_iam_policy" "mfa_policy" {
#   name        = "MFAEnforcementPolicy"
#   path        = "/policies/"
#   description = "Enforces MFA for all users - denies access without MFA"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "AllowViewAccountInfo"
#         Effect = "Allow"
#         Action = [
#           "iam:GetAccountPasswordPolicy",
#           "iam:ListVirtualMFADevices"
#         ]
#         Resource = "*"
#       },
#       {
#         Sid    = "AllowManageOwnPasswords"
#         Effect = "Allow"
#         Action = [
#           "iam:ChangePassword",
#           "iam:GetUser"
#         ]
#         Resource = "arn:aws:iam::*:user/$${aws:username}"
#       },
#       {
#         Sid    = "AllowManageOwnMFA"
#         Effect = "Allow"
#         Action = [
#           "iam:CreateVirtualMFADevice",
#           "iam:DeleteVirtualMFADevice",
#           "iam:EnableMFADevice",
#           "iam:ListMFADevices",
#           "iam:ResyncMFADevice"
#         ]
#         Resource = [
#           "arn:aws:iam::*:mfa/$${aws:username}",
#           "arn:aws:iam::*:user/$${aws:username}"
#         ]
#       },
#       {
#         Sid    = "DenyAllExceptUnlessSignedInWithMFA"
#         Effect = "Deny"
#         NotAction = [
#           "iam:CreateVirtualMFADevice",
#           "iam:EnableMFADevice",
#           "iam:GetUser",
#           "iam:ListMFADevices",
#           "iam:ListVirtualMFADevices",
#           "iam:ResyncMFADevice",
#           "sts:GetSessionToken",
#           "iam:ChangePassword"
#         ]
#         Resource = "*"
#         Condition = {
#           BoolIfExists = {
#             "aws:MultiFactorAuthPresent" = "false"
#           }
#         }
#       }
#     ]
#   })
# }

# Attach policies to groups
resource "aws_iam_group_policy_attachment" "education_policy_attachment" {
  group      = aws_iam_group.education.name
  policy_arn = aws_iam_policy.education_policy.arn
}

resource "aws_iam_group_policy_attachment" "sales_policy_attachment" {
  group      = aws_iam_group.sales.name
  policy_arn = aws_iam_policy.sales_policy.arn
}

resource "aws_iam_group_policy_attachment" "corporate_policy_attachment" {
  group      = aws_iam_group.corporate.name
  policy_arn = aws_iam_policy.corporate_policy.arn
}

resource "aws_iam_group_policy_attachment" "managers_policy_attachment" {
  group      = aws_iam_group.managers.name
  policy_arn = aws_iam_policy.managers_policy.arn
}

# # Attach MFA policy to all groups (everyone must use MFA)
# resource "aws_iam_group_policy_attachment" "education_mfa_attachment" {
#   group      = aws_iam_group.education.name
#   policy_arn = aws_iam_policy.mfa_policy.arn
# }

# resource "aws_iam_group_policy_attachment" "sales_mfa_attachment" {
#   group      = aws_iam_group.sales.name
#   policy_arn = aws_iam_policy.mfa_policy.arn
# }

# resource "aws_iam_group_policy_attachment" "corporate_mfa_attachment" {
#   group      = aws_iam_group.corporate.name
#   policy_arn = aws_iam_policy.mfa_policy.arn
# }

# resource "aws_iam_group_policy_attachment" "managers_mfa_attachment" {
#   group      = aws_iam_group.managers.name
#   policy_arn = aws_iam_policy.mfa_policy.arn
# }