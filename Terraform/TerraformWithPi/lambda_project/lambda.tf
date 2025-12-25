
# Lambda Layer - Contains external libraries (like Pillow for image processing)
# Layers allow you to package libraries separately from your function code
# COMMENTED OUT: Uncomment when you have pillow_layer.zip file
# resource "aws_lambda_layer_version" "pillow_layer" {
#   filename         = "${path.module}/pillow_layer.zip"  # Pre-built layer with Pillow library
#   layer_name       = "${var.project_name}-pillow-layer"
#   compatible_runtimes = ["python3.12"]  # Python version compatibility
#   description = "Pillow library layer for image processing"
#   
#   # Note: To create pillow_layer.zip:
#   # mkdir python && pip install pillow -t python/ && zip -r pillow_layer.zip python/
# }

# Lambda Function - The serverless compute service
# This is the main Lambda function that processes S3 events
resource "aws_lambda_function" "image_processor" {
  filename         = data.archive_file.lambda_zip.output_path    # ZIP file with code
  function_name    = local.lambda_function_name                 # Function name in AWS
  role            = aws_iam_role.lambda_role.arn               # IAM role for permissions
  handler         = "lambda_function.lambda_handler"           # Entry point: file.function
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256  # Detects code changes
  runtime         = "python3.12"                              # Python version
  timeout         = 60                                         # Max execution time (seconds)
  memory_size     = 1024                                       # Memory allocation (MB)

  # Attach the Pillow layer (commented out until layer exists)
  # layers = [aws_lambda_layer_version.pillow_layer.arn]

  # Environment variables - passed to your Lambda function
  environment {
    variables = {
      PROCESSED_BUCKET = aws_s3_bucket.processed_bucket.id  # Where to store processed files
      LOG_LEVEL       = "INFO"                              # Logging level
    }
  }
  
  tags = {
    Name        = local.lambda_function_name
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Process S3 upload events"
  }
}

# CloudWatch Log Group - Stores Lambda function logs
# Lambda automatically writes logs here for debugging and monitoring
resource "aws_cloudwatch_log_group" "lambda_processor" {
  name              = "/aws/lambda/${local.lambda_function_name}"  # Standard Lambda log group naming
  retention_in_days = 7                                           # Keep logs for 7 days
  
  tags = {
    Name        = "${local.lambda_function_name}-logs"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Lambda function logs"
  }
}

# Lambda Permission - Allows S3 to invoke the Lambda function
# Without this, S3 cannot trigger your Lambda function
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"                    # Unique identifier
  action        = "lambda:InvokeFunction"                   # Permission to invoke
  function_name = aws_lambda_function.image_processor.function_name
  principal     = "s3.amazonaws.com"                        # S3 service can invoke
  source_arn    = aws_s3_bucket.upload_bucket.arn          # Only this bucket can invoke
}

# S3 Bucket Notification - Triggers Lambda when files are uploaded
# This is what makes Lambda run automatically when files are uploaded to S3
resource "aws_s3_bucket_notification" "upload_bucket_notification" {
  bucket = aws_s3_bucket.upload_bucket.id

  # Lambda function configuration for S3 events
  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]  # Trigger on any file upload
    # Optional filters (uncomment to use):
    # filter_prefix       = "uploads/"              # Only files in uploads/ folder
    # filter_suffix       = ".jpg"                 # Only .jpg files
  }

  # Ensure permission is created before notification
  depends_on = [aws_lambda_permission.allow_s3]
}