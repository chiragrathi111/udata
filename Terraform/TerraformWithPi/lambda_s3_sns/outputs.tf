output "s3_bucket_name" {
  description = "S3 bucket name for file uploads"
  value       = aws_s3_bucket.s3_upload_bucket.id
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.s3_sns_processor.function_name
}

output "sns_topic_arn" {
  description = "SNS topic ARN"
  value       = aws_sns_topic.s3_upload_notifications.arn
}

output "test_command" {
  description = "Command to test the system"
  value       = "aws s3 cp test.txt s3://${aws_s3_bucket.s3_upload_bucket.id}/"
}
