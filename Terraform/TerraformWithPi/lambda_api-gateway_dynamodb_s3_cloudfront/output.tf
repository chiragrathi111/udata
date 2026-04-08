# ============================================================
# IMPORTANT URLS - You need these after deployment
# ============================================================

# This is your FRONTEND URL - open in browser to see Student Portal
output "frontend_url" {
  description = "🌐 Open this URL in browser to see your Student Portal"
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

# This is your BACKEND API URL - use in Postman for testing
output "api_url" {
  description = "🔗 API Gateway URL for Postman testing"
  value       = "${aws_api_gateway_stage.api_stage.invoke_url}/students"
}

# CloudFront distribution ID - needed to clear cache
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (for cache invalidation)"
  value       = aws_cloudfront_distribution.frontend.id
}

# S3 bucket name
output "s3_bucket_name" {
  description = "S3 bucket hosting frontend files"
  value       = aws_s3_bucket.frontend.id
}

# DynamoDB table name
output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.students.name
}

# Lambda function name
output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.lambda_function.function_name
}

# Quick start guide after deployment
output "next_steps" {
  description = "What to do after deployment"
  value       = <<-EOT

    ✅ Deployment Complete!

    1. FRONTEND (Browser):
       https://${aws_cloudfront_distribution.frontend.domain_name}
       (CloudFront takes 5-10 min to deploy, be patient!)

    2. BACKEND API (Postman):
       ${aws_api_gateway_stage.api_stage.invoke_url}/students

    3. If frontend shows old data, clear CloudFront cache:
       aws cloudfront create-invalidation \
         --distribution-id ${aws_cloudfront_distribution.frontend.id} \
         --paths "/*"

  EOT
}
