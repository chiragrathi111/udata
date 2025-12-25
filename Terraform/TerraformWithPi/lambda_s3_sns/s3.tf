# Random ID for unique resource naming
resource "random_id" "suffix" {
   byte_length = 4  # Creates 8-character hex string for uniqueness
}

# S3 Bucket - Where users upload files that trigger Lambda
# This bucket will send notifications to Lambda when objects are created
resource "aws_s3_bucket" "s3_upload_bucket" {
    bucket = "${var.project_name}-upload-${random_id.suffix.hex}"
    
    tags = {
      Name    = "${var.project_name}-upload-bucket"
      Purpose = "S3 bucket for file uploads that trigger Lambda"
    }
}

# Enable versioning on S3 bucket - keeps file history
resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = aws_s3_bucket.s3_upload_bucket.id
  versioning_configuration {
    status = "Enabled"  # Keep multiple versions of uploaded files
  }
}

# Block all public access - security best practice
resource "aws_s3_bucket_public_access_block" "s3_security" {
  bucket = aws_s3_bucket.s3_upload_bucket.id

  block_public_acls       = true  # Block public ACLs
  block_public_policy     = true  # Block public bucket policies
  ignore_public_acls      = true  # Ignore existing public ACLs
  restrict_public_buckets = true  # Restrict public bucket policies
}

# Encrypt all files in bucket - security best practice
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.s3_upload_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # AWS managed encryption
    }
  }
}

# S3 Bucket Notification - Triggers Lambda when files are uploaded
# This is what makes Lambda run automatically when files are uploaded
resource "aws_s3_bucket_notification" "s3_lambda_trigger" {
  bucket = aws_s3_bucket.s3_upload_bucket.id

  # Lambda function configuration for S3 events
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_sns_processor.arn
    events              = ["s3:ObjectCreated:*"]  # Trigger on any file upload
    # Optional filters:
    # filter_prefix       = "uploads/"              # Only files in uploads/ folder
    # filter_suffix       = ".jpg"                 # Only specific file types
  }

  # Ensure Lambda permission is created before notification
  depends_on = [aws_lambda_permission.s3_invoke_lambda]
}

