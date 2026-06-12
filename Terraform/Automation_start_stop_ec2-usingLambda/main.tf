# IAM Role for Lambda
# Lambda needs a role to call other AWS services (EC2, CloudWatch Logs)
# The assume_role_policy says: "Lambda service is allowed to use this role"
resource "aws_iam_role" "lambda_ec2_role" {
  name = "lambda-ec2-start-stop-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com" # Only Lambda can assume this role
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Inline policy attached to the role above
# Grants Lambda permission to start/stop EC2 and write logs to CloudWatch
resource "aws_iam_role_policy" "lambda_ec2_policy" {
  name = "lambda-ec2-start-stop-policy"
  role = aws_iam_role.lambda_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # EC2 permissions: allow start, stop, and describe (describe needed to check state)
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ]
        Resource = "*" # EC2 start/stop API does not support resource-level restriction at instance ARN
      },
      {
        # CloudWatch Logs: Lambda writes execution logs here for debugging
        # Without this, you can't see print() output from the Python function
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
    ]
  })
}
