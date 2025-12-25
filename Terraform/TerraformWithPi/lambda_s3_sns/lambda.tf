# Archive Lambda function code into ZIP file
# Terraform will create a ZIP file from your Python code
data "archive_file" "lambda_s3_sns_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/s3.py"     # Path to your Python file
  output_path = "${path.module}/lambda/s3.zip"    # ZIP file Terraform creates
}

# Lambda Function - Processes S3 events and sends SNS notifications
# This function runs automatically when files are uploaded to S3
resource "aws_lambda_function" "s3_sns_processor" {
  function_name    = "${var.project_name}-s3-sns-processor"
  filename         = data.archive_file.lambda_s3_sns_zip.output_path    # ZIP file with code
  source_code_hash = data.archive_file.lambda_s3_sns_zip.output_base64sha256  # Detects code changes
  role            = aws_iam_role.lambda_s3_sns_role.arn                # IAM role for permissions
  handler         = "s3.lambda_handler"                                # Entry point: file.function
  runtime         = "python3.10"                                       # Python version
  timeout         = 60                                                 # Max execution time (seconds)
  memory_size     = 1024                                               # Memory allocation (MB)

  # Environment variables - passed to your Lambda function
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.s3_upload_notifications.arn  # SNS topic to publish to
      REGION        = var.region                                  # AWS region
    }
  }
  
  tags = {
    Name    = "${var.project_name}-s3-sns-processor"
    Purpose = "Process S3 uploads and send email notifications"
  }
}

# Lambda Permission - Allows S3 to invoke the Lambda function
# Without this, S3 cannot trigger your Lambda function
resource "aws_lambda_permission" "s3_invoke_lambda" {
    statement_id  = "AllowExecutionFromS3"                           # Unique identifier
    action        = "lambda:InvokeFunction"                          # Permission to invoke
    function_name = aws_lambda_function.s3_sns_processor.function_name
    principal     = "s3.amazonaws.com"                               # S3 service can invoke
    source_arn    = aws_s3_bucket.s3_upload_bucket.arn              # Only this bucket can invoke
}

# CloudWatch Log Group - Stores Lambda function logs
# Lambda automatically writes logs here for debugging and monitoring
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.s3_sns_processor.function_name}"
  retention_in_days = 7  # Keep logs for 7 days
  
  tags = {
    Name    = "${var.project_name}-lambda-logs"
    Purpose = "Lambda function logs for debugging"
  }
}