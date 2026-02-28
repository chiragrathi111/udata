output "api_gateway_url" {
  description = "API Gateway invoke URL"
  value       = aws_api_gateway_stage.order_stage.invoke_url
}

output "api_endpoint_full" {
  description = "Full API endpoint URL for order submission"
  value       = "${aws_api_gateway_stage.order_stage.invoke_url}${aws_api_gateway_resource.order_api.path}"
}

output "sqs_queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.order_queue.url
}

output "sqs_queue_arn" {
  description = "SQS queue ARN"
  value       = aws_sqs_queue.order_queue.arn
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.orders.name
}

output "sns_topic_arn" {
  description = "SNS topic ARN for notifications"
  value       = aws_sns_topic.order_topic.arn
}

output "lambda_producer_name" {
  description = "Producer Lambda function name"
  value       = aws_lambda_function.lambda_producer.function_name
}

output "lambda_consumer_name" {
  description = "Consumer Lambda function name"
  value       = aws_lambda_function.lambda_consumer.function_name
}

output "test_command" {
  description = "curl command to test the API"
  value       = <<-EOT
    curl -X POST ${aws_api_gateway_stage.order_stage.invoke_url}${aws_api_gateway_resource.order_api.path} \
      -H "Content-Type: application/json" \
      -d '{"productId": "PROD-001", "quantity": 3, "customer": "Test User", "price": 29.99}'
  EOT
}
