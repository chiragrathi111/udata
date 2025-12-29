# Output the complete API endpoint URL for Postman testing
output "api_endpoint_url" {
  description = "Complete API Gateway endpoint URL for /hello endpoint"
  value       = "${aws_api_gateway_stage.lambda_api_stage.invoke_url}/hello"
}

# Output the complete API endpoint URL for POST /users
output "users_endpoint_url" {
  description = "Complete API Gateway endpoint URL for POST /users endpoint"
  value       = "${aws_api_gateway_stage.lambda_api_stage.invoke_url}/users"
}

# Output base API URL (without endpoint path)
output "api_base_url" {
  description = "Base API Gateway URL"
  value       = aws_api_gateway_stage.lambda_api_stage.invoke_url
}

# Commands to get output data:
# terraform output                    - Shows all outputs
# terraform output users_endpoint_url - Shows POST endpoint URL
# terraform output -json              - Shows outputs in JSON format
# terraform output -raw users_endpoint_url - Clean URL for Postman
#
# Postman Usage:
# Method: POST
# URL: Use users_endpoint_url output
# Headers: Content-Type: application/json
# Body (raw JSON): {"name": "John Doe", "age": 25}