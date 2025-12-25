# Random suffix to ensure unique resource names across AWS
resource "random_id" "suffix" {
  byte_length = 4  # Creates 8-character hex string
}

# Local values - computed names for all resources
locals {
  # Base prefix for all resources using project and environment
  bucket_prefix = "${var.project_name}-${var.environment}"
  
  # S3 bucket names (must be globally unique)
  upload_bucket_name = "${local.bucket_prefix}-upload-${random_id.suffix.hex}"
  processed_bucket_name = "${local.bucket_prefix}-processed-${random_id.suffix.hex}"
  
  # Lambda function name (alphanumeric, hyphens, underscores only)
  lambda_function_name = "${var.project_name}-${var.environment}-processor"
  
  # IAM role name (alphanumeric, hyphens, underscores only)
  lambda_role_name = "${var.project_name}-${var.environment}-lambda-role"
}

# S3 Upload Bucket - Where users upload files for processing
resource "aws_s3_bucket" "upload_bucket" {
  bucket = local.upload_bucket_name  # Globally unique name

  tags = {
    Name        = local.upload_bucket_name
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "File uploads for Lambda processing"
  }
}

# Enable versioning on upload bucket - keeps file history
resource "aws_s3_bucket_versioning" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id
  versioning_configuration {
    status = "Enabled"  # Keeps multiple versions of files
  }
}

# Encrypt all files in upload bucket - security best practice
resource "aws_s3_bucket_server_side_encryption_configuration" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # AWS managed encryption
    }
  }
}

# Block all public access to upload bucket - security best practice
resource "aws_s3_bucket_public_access_block" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id

  block_public_acls       = true  # Block public ACLs
  block_public_policy     = true  # Block public bucket policies
  ignore_public_acls      = true  # Ignore existing public ACLs
  restrict_public_buckets = true  # Restrict public bucket policies
}

# S3 Processed Bucket - Where Lambda stores processed files
resource "aws_s3_bucket" "processed_bucket" {
  bucket = local.processed_bucket_name  # Globally unique name
  
  tags = {
    Name        = local.processed_bucket_name
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Processed files from Lambda function"
  }
}

# Enable versioning on processed bucket
resource "aws_s3_bucket_versioning" "processed_bucket" {
  bucket = aws_s3_bucket.processed_bucket.id
  versioning_configuration {
    status = "Enabled"  # Keeps multiple versions of processed files
  }
}

# Encrypt all files in processed bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "processed_bucket" {
  bucket = aws_s3_bucket.processed_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # AWS managed encryption
    }
  }
}

# Block all public access to processed bucket
resource "aws_s3_bucket_public_access_block" "processed_bucket" {
  bucket = aws_s3_bucket.processed_bucket.id

  block_public_acls       = true  # Security: No public access
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}