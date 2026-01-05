# =============================================================================
# PROJECT OUTPUTS - Important information after deployment
# =============================================================================

output "upload_bucket_name" {
  description = "Name of the S3 bucket where users upload images"
  value       = module.upload_bucket.bucket_name
}

output "upload_bucket_url" {
  description = "S3 Console URL for the upload bucket"
  value       = "https://s3.console.aws.amazon.com/s3/buckets/${module.upload_bucket.bucket_name}"
}

output "processed_bucket_name" {
  description = "Name of the S3 bucket where processed images are stored"
  value       = module.processed_bucket.bucket_name
}

output "processed_bucket_url" {
  description = "S3 Console URL for the processed bucket"
  value       = "https://s3.console.aws.amazon.com/s3/buckets/${module.processed_bucket.bucket_name}"
}

output "lambda_function_name" {
  description = "Name of the Lambda function processing images"
  value       = module.lambda.function_name
}

output "lambda_function_url" {
  description = "AWS Console URL for the Lambda function"
  value       = "https://console.aws.amazon.com/lambda/home?region=${var.region}#/functions/${module.lambda.function_name}"
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL for monitoring"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:"
}

output "sns_topics" {
  description = "SNS topic ARNs for notifications"
  value = {
    critical = module.critical_sns.topic_arn
    normal   = module.normal_sns.topic_arn
  }
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    project_name      = var.project_name
    environment       = var.environment
    region           = var.region
    upload_bucket    = module.upload_bucket.bucket_name
    processed_bucket = module.processed_bucket.bucket_name
    lambda_function  = module.lambda.function_name
    notification_email = var.notification_email
  }
}