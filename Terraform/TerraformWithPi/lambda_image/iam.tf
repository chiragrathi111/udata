# IAM Role for Lambda Function - Allows Lambda to access AWS services
resource "aws_iam_role" "lambda_image" {
  name = "${var.project_name}-role-${var.environment}"

  # Trust policy - allows Lambda service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "${var.project_name}-lambda-role-${var.environment}"
    Environment = var.environment
  }
}

# IAM Policy for Lambda Function - Defines specific permissions
resource "aws_iam_role_policy" "lambda_image_policy" {
  name = "${var.project_name}-policy-${var.environment}"
  role = aws_iam_role.lambda_image.id
  
  # Policy document - specific permissions Lambda needs
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # CloudWatch Logs permissions - for Lambda logging
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        # S3 Read permissions - for reading from upload bucket
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"  # Fixed typo: was "GetObjectVerion"
        ]
        Resource = "${aws_s3_bucket.upload_bucket.arn}/*"
      },
      {
        # S3 Write permissions - for writing to destination bucket
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${aws_s3_bucket.destination_bucket.arn}/*"
      }
    ]
  })
}