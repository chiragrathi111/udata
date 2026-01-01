# Random ID for unique bucket names
# Ensures bucket names are globally unique across AWS
resource "random_id" "suffix" {
  byte_length = 4
}

# S3 Upload Bucket - Where users upload files
# This bucket triggers Lambda when objects are uploaded
resource "aws_s3_bucket" "upload_bucket" {
  bucket = "${lower(var.project_name)}-upload-${var.environment}-${random_id.suffix.hex}"

  tags = {
    Name        = "${var.project_name}-upload-${var.environment}"
    Environment = var.environment
    Purpose     = "File upload bucket for Lambda processing"
  }
}

resource "aws_s3_bucket_versioning" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

# S3 Destination Bucket - Where processed files are stored
# Lambda copies files here and creates processing records
resource "aws_s3_bucket" "destination_bucket" {
  bucket = "${lower(var.project_name)}-destination-${var.environment}-${random_id.suffix.hex}"

  tags = {
    Name        = "${var.project_name}-destination-${var.environment}"
    Environment = var.environment
    Purpose     = "Destination bucket for processed files and records"
  }
}

resource "aws_s3_bucket_versioning" "destination_bucket" {
  bucket = aws_s3_bucket.destination_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "destination_bucket" {
  bucket = aws_s3_bucket.destination_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "destination_bucket" {
  bucket = aws_s3_bucket.destination_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

