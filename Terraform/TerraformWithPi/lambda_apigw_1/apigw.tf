# API Gateway Configuration for Lambda Integration
# API Gateway creates REST APIs that can trigger Lambda functions

# API Gateway REST API - The main API that clients will call
# This creates the base API that will have endpoints (resources and methods)
resource "aws_api_gateway_rest_api" "lambda_api" {
  name        = "${var.project_name}-api"
  description = "API Gateway for Lambda function integration"
  
  # API Gateway endpoint configuration
  endpoint_configuration {
    types = ["REGIONAL"]  # Regional endpoint (cheaper than EDGE)
  }
  
  tags = {
    Name    = "${var.project_name}-api"
    Purpose = "REST API for Lambda function"
  }
}

# API Gateway Resource - Defines the URL path structure
# This creates the /hello endpoint in your API
resource "aws_api_gateway_resource" "hello_resource" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  path_part   = "hello"  # This creates /hello endpoint
}

# API Gateway Method - Defines HTTP method (GET, POST, etc.)
# This allows GET requests to /hello endpoint
resource "aws_api_gateway_method" "hello_get" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  resource_id   = aws_api_gateway_resource.hello_resource.id
  http_method   = "GET"                    # HTTP GET method
  authorization = "NONE"                   # No authentication required
  
  # Enable query parameters (like ?name=John)
  request_parameters = {
    "method.request.querystring.name" = false  # Optional query parameter
  }
}

# API Gateway Integration - Connects API Gateway to Lambda
# This tells API Gateway how to call your Lambda function
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.hello_get.http_method

  integration_http_method = "POST"                                    # Lambda always uses POST
  type                   = "AWS_PROXY"                               # Lambda proxy integration
  uri                    = aws_lambda_function.lambda_apigw.invoke_arn # Lambda function ARN
}

# API Gateway Method Response - Defines response structure
# This tells API Gateway what responses to expect from Lambda
resource "aws_api_gateway_method_response" "hello_response_200" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = "200"  # HTTP 200 OK response

  # Response headers that API Gateway can return
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true  # CORS header
  }
  
  # Response models (optional - defines response structure)
  response_models = {
    "application/json" = "Empty"
  }
}

# API Gateway Integration Response - Maps Lambda response to API response
# This tells API Gateway how to handle Lambda function responses
resource "aws_api_gateway_integration_response" "lambda_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = aws_api_gateway_method_response.hello_response_200.status_code

  # Response headers
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"  # Allow CORS from any origin
  }

  depends_on = [aws_api_gateway_integration.lambda_integration]
}

# Lambda Permission - Allows API Gateway to invoke Lambda function
# Without this, API Gateway cannot call your Lambda function
resource "aws_lambda_permission" "apigw_invoke_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_apigw.function_name
  principal     = "apigateway.amazonaws.com"

  # Allow API Gateway to invoke Lambda from any stage and method
  source_arn = "${aws_api_gateway_rest_api.lambda_api.execution_arn}/*/*"
}

# API Gateway Deployment - Makes the API available to the public
# This creates a "stage" of your API that can be called from the internet
resource "aws_api_gateway_deployment" "lambda_api_deployment" {
  depends_on = [
    aws_api_gateway_method.hello_get,
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration_response.lambda_integration_response
  ]

  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  
  # Force new deployment when configuration changes
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.hello_resource.id,
      aws_api_gateway_method.hello_get.id,
      aws_api_gateway_integration.lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage - Manages different versions of your API
# Stages allow you to have dev, staging, prod versions
resource "aws_api_gateway_stage" "lambda_api_stage" {
  deployment_id = aws_api_gateway_deployment.lambda_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  stage_name    = var.api_stage_name
  
  # Enable logging and monitoring
  xray_tracing_enabled = true  # Enable X-Ray tracing for debugging
  
  tags = {
    Name    = "${var.project_name}-api-${var.api_stage_name}"
    Purpose = "API Gateway stage for Lambda integration"
  }
}

# CloudWatch Log Group for API Gateway logs
# API Gateway can log all requests here for monitoring
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.lambda_api.id}/${var.api_stage_name}"
  retention_in_days = 7
  
  tags = {
    Name    = "${var.project_name}-api-logs"
    Purpose = "API Gateway request logs"
  }
}

# API Gateway Account Settings - Enable CloudWatch logging
# This allows API Gateway to write logs to CloudWatch
resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_role.arn
}

# IAM Role for API Gateway CloudWatch logging
resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name = "${var.project_name}-api-gateway-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for API Gateway CloudWatch logging
resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_policy" {
  role       = aws_iam_role.api_gateway_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}