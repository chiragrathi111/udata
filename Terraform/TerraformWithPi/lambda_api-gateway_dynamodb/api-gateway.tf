# ============================================================
# API Gateway REST API
# ============================================================
resource "aws_api_gateway_rest_api" "student_api" {
  name        = "${var.project_name}-api"
  description = "Student Management CRUD API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# ============================================================
# Resource: /students
# ============================================================
resource "aws_api_gateway_resource" "students" {
  rest_api_id = aws_api_gateway_rest_api.student_api.id
  parent_id   = aws_api_gateway_rest_api.student_api.root_resource_id
  path_part   = "students"
}

# ============================================================
# GET /students
# ============================================================
resource "aws_api_gateway_method" "get_students" {
  rest_api_id   = aws_api_gateway_rest_api.student_api.id
  resource_id   = aws_api_gateway_resource.students.id
  http_method   = "GET"
  authorization = "NONE" # For simplicity, we're not using any authorization here. In a production app, consider using AWS_IAM or a custom authorizer.
}

resource "aws_api_gateway_integration" "get_students" {
  rest_api_id             = aws_api_gateway_rest_api.student_api.id
  resource_id             = aws_api_gateway_resource.students.id
  http_method             = aws_api_gateway_method.get_students.http_method
  integration_http_method = "POST" # For AWS_PROXY, this is typically POST regardless of the actual HTTP method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.student_management.invoke_arn
}

# ============================================================
# POST /students
# ============================================================
resource "aws_api_gateway_method" "post_students" {
  rest_api_id   = aws_api_gateway_rest_api.student_api.id
  resource_id   = aws_api_gateway_resource.students.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_students" {
  rest_api_id             = aws_api_gateway_rest_api.student_api.id
  resource_id             = aws_api_gateway_resource.students.id
  http_method             = aws_api_gateway_method.post_students.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.student_management.invoke_arn
}

# ============================================================
# PUT /students
# ============================================================
resource "aws_api_gateway_method" "put_students" {
  rest_api_id   = aws_api_gateway_rest_api.student_api.id
  resource_id   = aws_api_gateway_resource.students.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "put_students" {
  rest_api_id             = aws_api_gateway_rest_api.student_api.id
  resource_id             = aws_api_gateway_resource.students.id
  http_method             = aws_api_gateway_method.put_students.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.student_management.invoke_arn
}

# ============================================================
# DELETE /students
# ============================================================
resource "aws_api_gateway_method" "delete_students" {
  rest_api_id   = aws_api_gateway_rest_api.student_api.id
  resource_id   = aws_api_gateway_resource.students.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_students" {
  rest_api_id             = aws_api_gateway_rest_api.student_api.id
  resource_id             = aws_api_gateway_resource.students.id
  http_method             = aws_api_gateway_method.delete_students.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.student_management.invoke_arn
}

# ============================================================
# CORS - OPTIONS method
# For handling CORS preflight requests
# ============================================================
resource "aws_api_gateway_method" "options_students" {
  rest_api_id   = aws_api_gateway_rest_api.student_api.id
  resource_id   = aws_api_gateway_resource.students.id
  http_method   = "OPTIONS" # CORS preflight requests use the OPTIONS method
  authorization = "NONE" # For simplicity, we're not using any authorization here. In a production app, consider using AWS_IAM or a custom authorizer.
}

resource "aws_api_gateway_integration" "options_students" {
  rest_api_id = aws_api_gateway_rest_api.student_api.id
  resource_id = aws_api_gateway_resource.students.id
  http_method = aws_api_gateway_method.options_students.http_method
  type        = "MOCK" # A MOCK integration allows us to return a response without calling any backend, which is perfect for CORS preflight requests

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.student_api.id
  resource_id = aws_api_gateway_resource.students.id
  http_method = aws_api_gateway_method.options_students.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.student_api.id
  resource_id = aws_api_gateway_resource.students.id
  http_method = aws_api_gateway_method.options_students.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options_students]
}

# ============================================================
# Deployment & Stage - THIS GIVES YOU THE POSTMAN URL
# ============================================================
resource "aws_api_gateway_deployment" "student_api" {
  rest_api_id = aws_api_gateway_rest_api.student_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.get_students.id,
      aws_api_gateway_integration.get_students.id,
      aws_api_gateway_method.post_students.id,
      aws_api_gateway_integration.post_students.id,
      aws_api_gateway_method.put_students.id,
      aws_api_gateway_integration.put_students.id,
      aws_api_gateway_method.delete_students.id,
      aws_api_gateway_integration.delete_students.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "student_api" {
  deployment_id = aws_api_gateway_deployment.student_api.id
  rest_api_id   = aws_api_gateway_rest_api.student_api.id
  stage_name    = "prod"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
