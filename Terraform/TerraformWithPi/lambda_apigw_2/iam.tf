# IAM Role for Lambda Function - Allows Lambda to access AWS services
resource "aws_iam_role" "lambda_apigw_role" {
  name = "${var.project_name}-lambda-role"

  # Trust policy - allows Lambda service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"  # Lambda can assume this role
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"  # Only Lambda service can use this role
        }
      },
    ]
  })
  
  tags = {
    Name    = "${var.project_name}-lambda-role"
    Purpose = "IAM role for Lambda API Gateway integration"
  }
}

# IAM Policy for Lambda Function - Defines specific permissions
resource "aws_iam_role_policy" "lambda_apigw_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_apigw_role.id

  # Policy document - specific permissions Lambda needs
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # CloudWatch Logs permissions - for Lambda logging
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",    # Create log groups
          "logs:CreateLogStream",   # Create log streams
          "logs:PutLogEvents"       # Write log events
        ]
        Resource = "arn:aws:logs:${var.region}:*:*"
      }
    ]
  })
}