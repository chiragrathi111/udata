# Iam role for lambda function
resource "aws_iam_role" "lambda" {
  name = "aws_lambda_test5515"
  
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
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# Create ZIP file from Python source code
# This ensures the ZIP contains the correct file structure
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/hello.py"  # Source Python file
  output_path = "${path.module}/hello.zip"        # Output ZIP file
}

# Lambda Function with correct handler reference
resource "aws_lambda_function" "lambda_1" {
  function_name    = "aws_lambda_test5515"
  filename         = data.archive_file.lambda_zip.output_path  # Use generated ZIP
  handler          = "hello.lambda_handler"                   # FIXED: file_name.function_name
  role            = aws_iam_role.lambda.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256  # Detects code changes
  runtime         = "python3.10"
  timeout         = 60
  memory_size     = 1024
  
  tags = {
    Name = "aws_lambda_test5515"
    Purpose = "Test Lambda function"
  }
}