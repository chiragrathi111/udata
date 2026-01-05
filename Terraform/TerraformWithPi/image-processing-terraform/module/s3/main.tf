# =============================================================================
# S3 MODULE - Secure and scalable object storage for images
# =============================================================================
# This module creates S3 buckets with proper security, versioning, and
# lifecycle policies for storing original and processed images
# =============================================================================

# Main S3 bucket for storing images
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  
  tags = merge(var.tags, {
    Name    = var.bucket_name
    Purpose = var.bucket_purpose
  })
}

# Enable versioning for data protection
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption for security
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block public access for security
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy to manage storage costs
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "transition_to_ia"
    status = "Enabled"

    # Move to Infrequent Access after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Move to Glacier after 90 days
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Delete after 365 days (optional)
    expiration {
      days = 365
    }
  }
}

# Lambda trigger notification (only for upload bucket)
resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.this.id

  dynamic "lambda_function" {
    for_each = var.lambda_arn != null ? [1] : []
    content {
      lambda_function_arn = var.lambda_arn
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = ""
      filter_suffix       = ""
    }
  }

  depends_on = [var.lambda_permission]
}
