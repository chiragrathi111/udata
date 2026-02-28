output "api_endpoint_url" {
  description = "Complete API Gateway endpoint URL for /hello endpoint"
  value       = "${aws_api_gateway_stage.lambda_api_stage.invoke_url}/hello"
}

output "api_base_url" {
  description = "Base API Gateway URL"
  value       = aws_api_gateway_stage.lambda_api_stage.invoke_url
}

output "api_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.lambda_api.id
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.lambda_apigw.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.lambda_apigw.arn
}

output "test_commands" {
  description = "Commands to test the API"
  value       = <<-EOT
    # Test without parameter
    curl ${aws_api_gateway_stage.lambda_api_stage.invoke_url}/hello
    
    # Test with name parameter
    curl "${aws_api_gateway_stage.lambda_api_stage.invoke_url}/hello?name=Alice"
    
    # Check Lambda logs
    aws logs tail /aws/lambda/${aws_lambda_function.lambda_apigw.function_name} --follow
  EOT
}
