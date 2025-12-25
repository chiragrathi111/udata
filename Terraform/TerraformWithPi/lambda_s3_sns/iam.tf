# IAM Role for Lambda Function - Defines what AWS services Lambda can access
resource "aws_iam_role" "lambda_s3_sns_role" {
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
    Purpose = "IAM role for Lambda S3-SNS processing"
  }
}

# IAM Policy for Lambda Function - Defines specific permissions
resource "aws_iam_role_policy" "lambda_s3_sns_policy" {
    name = "${var.project_name}-lambda-policy"
    role = aws_iam_role.lambda_s3_sns_role.id

    # Policy document - specific permissions Lambda needs
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                # S3 permissions - read uploaded files
                Effect = "Allow"
                Action = [
                    "s3:GetObject",      # Read files from S3
                    "s3:GetObjectVersion", # Read specific file versions
                    "s3:ListBucket"      # List bucket contents
                ]
                Resource = [
                  aws_s3_bucket.s3_upload_bucket.arn,      # Bucket itself
                  "${aws_s3_bucket.s3_upload_bucket.arn}/*" # All objects in bucket
                ]
            },
            {
                # SNS permissions - send email notifications
                Effect = "Allow"
                Action = [
                    "sns:Publish"  # Publish messages to SNS topic
                ]
                Resource = aws_sns_topic.s3_upload_notifications.arn
            },
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