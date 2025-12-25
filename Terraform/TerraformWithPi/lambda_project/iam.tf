# IAM Role for Lambda Function - Defines what AWS services Lambda can access
resource "aws_iam_role" "lambda_role" {
  name = local.lambda_role_name  # Must be unique within AWS account

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
    Name        = local.lambda_role_name
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Lambda execution role for S3 processing"
  }
}

# IAM Policy for Lambda Function - Defines specific permissions
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${local.lambda_function_name}-policy"
  role = aws_iam_role.lambda_role.id

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
        Resource = "arn:aws:logs:${var.aws_region}:*:*"
      },
      {
        # S3 Read permissions - read from upload bucket
        Effect = "Allow"
        Action = [
          "s3:GetObject",        # Read files
          "s3:GetObjectVersion"  # Read specific file versions
        ]
        Resource = [
          "${aws_s3_bucket.upload_bucket.arn}/*"  # All objects in upload bucket
        ]
      },
      {
        # S3 Write permissions - write to processed bucket
        Effect = "Allow"
        Action = [
          "s3:PutObject",     # Write files
          "s3:PutObjectAcl"   # Set file permissions
        ]
        Resource = [
          "${aws_s3_bucket.processed_bucket.arn}/*"  # All objects in processed bucket
        ]
      }
    ]
  })
}