# Archive Lambda function code into ZIP file
# Terraform creates ZIP from your Python source code
data "archive_file" "zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_image.py"
  output_path = "${path.module}/lambda_image.zip"
}

# Lambda Function for S3 Image Processing
# This function will be triggered when objects are uploaded to S3
resource "aws_lambda_function" "lambda_image_function" {
  function_name    = "${var.project_name}-function-${var.environment}"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  handler          = "lambda_image.lambda_handler"
  runtime          = "python3.10"
  memory_size      = var.memorySize
  timeout          = var.timeout
  role             = aws_iam_role.lambda_image.arn  # Fixed: Use correct IAM role name

  # Environment variables for Lambda function
  environment {
    variables = {
      DESTINATION_BUCKET = aws_s3_bucket.destination_bucket.id
      LOG_LEVEL         = "INFO"
    }
  }

  # Ensure CloudWatch log group exists before Lambda
  depends_on = [aws_cloudwatch_log_group.lambda_log]

  tags = {
    Name        = "${var.project_name}-lambda-${var.environment}"
    Environment = var.environment
  }
}

# Lambda Permission - Allows S3 to invoke Lambda function
# Without this, S3 cannot trigger your Lambda function
resource "aws_lambda_permission" "lambda_image" {
  statement_id  = "S3UploadImagesTriggerLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_image_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}

# S3 Bucket Notification - Triggers Lambda when objects are uploaded
# This creates the connection between S3 upload events and Lambda function
resource "aws_s3_bucket_notification" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id
  
  # Lambda function trigger configuration
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_image_function.arn
    events              = ["s3:ObjectCreated:*"]  # Trigger on any object creation
    # filter_prefix     = "images/"               # Optional: only trigger for specific prefix
    # filter_suffix     = ".jpg"                  # Optional: only trigger for specific file types
  }

  # Ensure Lambda permission exists before creating notification
  depends_on = [aws_lambda_permission.lambda_image]
}

# CloudWatch Log Group for Lambda function logs
# Lambda automatically writes logs here for debugging and monitoring
resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = "/aws/lambda/${var.project_name}-function-${var.environment}"
  retention_in_days = 7  # Keep logs for 7 days

  tags = {
    Name        = "${var.project_name}-lambda-logs-${var.environment}"
    Environment = var.environment
  }
}
