# =============================================================================
# IMAGE PROCESSING TERRAFORM PROJECT - MAIN CONFIGURATION
# =============================================================================
# This is the root module that orchestrates all components for an automated
# image processing pipeline using AWS services
# =============================================================================

# Random suffix to ensure unique bucket names across AWS
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# =============================================================================
# LAMBDA MODULE - Core image processing function
# =============================================================================
module "lambda" {
  source = "./module/lambda"
  
  # Lambda configuration
  function_name     = "${var.project_name}-processor"
  lambda_zip_path   = "${path.module}/lambda.zip"
  timeout           = var.lambda_timeout
  memory_size       = var.lambda_memory
  
  # S3 bucket permissions
  upload_bucket_arn    = module.upload_bucket.bucket_arn
  processed_bucket_arn = module.processed_bucket.bucket_arn
  
  # Environment variables for Lambda
  environment_variables = {
    PROCESSED_BUCKET = module.processed_bucket.bucket_name
    LOG_LEVEL       = "INFO"
  }
  
  tags = local.common_tags
}

# =============================================================================
# S3 BUCKETS - Upload and processed image storage
# =============================================================================

# Upload bucket - where users upload original images
module "upload_bucket" {
  source = "./module/s3"
  
  bucket_name        = "${var.project_name}-upload-${random_string.bucket_suffix.result}"
  bucket_purpose     = "upload"
  lambda_arn         = module.lambda.lambda_arn
  lambda_permission  = module.lambda.s3_permission
  
  tags = local.common_tags
}

# Processed bucket - where processed images are stored
module "processed_bucket" {
  source = "./module/s3"
  
  bucket_name    = "${var.project_name}-processed-${random_string.bucket_suffix.result}"
  bucket_purpose = "processed"
  
  # No Lambda trigger needed for processed bucket
  lambda_arn        = null
  lambda_permission = null
  
  tags = local.common_tags
}

# =============================================================================
# SNS TOPICS - Notification system
# =============================================================================

# Critical alerts for errors and failures
module "critical_sns" {
  source = "./module/sns"
  
  topic_name = "${var.project_name}-critical-alerts"
  email      = var.notification_email
  
  tags = local.common_tags
}

# Normal alerts for successful processing
module "normal_sns" {
  source = "./module/sns"
  
  topic_name = "${var.project_name}-normal-alerts"
  email      = var.notification_email
  
  tags = local.common_tags
}

# =============================================================================
# CLOUDWATCH - Monitoring and alerting
# =============================================================================
module "cloudwatch" {
  source = "./module/cloudwatch"
  
  # Lambda function name for log group
  lambda_function_name = module.lambda.function_name
  
  # SNS topic ARNs for notifications
  critical_sns_arn = module.critical_sns.topic_arn
  normal_sns_arn   = module.normal_sns.topic_arn
  
  # Project configuration
  project_name = var.project_name
  
  tags = local.common_tags
}

# =============================================================================
# LOCAL VALUES - Common configurations
# =============================================================================
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "ImageProcessing"
  }
}
