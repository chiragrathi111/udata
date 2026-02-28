resource "aws_api_gateway_rest_api" "rest_api" {
  name = "rest_api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "order_api" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "order"
  depends_on  = [aws_api_gateway_rest_api.rest_api]
}

resource "aws_api_gateway_method" "post" {
    rest_api_id = aws_api_gateway_rest_api.rest_api.id
    resource_id = aws_api_gateway_resource.order_api.id
    http_method = "POST"
    authorization = "NONE"
    depends_on = [aws_api_gateway_resource.order_api]
}

resource "aws_api_gateway_integration" "order_interation" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.order_api.id
  http_method = aws_api_gateway_method.post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_producer.invoke_arn
}

resource "aws_api_gateway_method_response" "order_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.order_api.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "order_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.order_api.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = aws_api_gateway_method_response.order_response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [ aws_api_gateway_integration.order_interation ]
}

resource "aws_api_gateway_deployment" "order_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  depends_on = [ aws_api_gateway_integration.order_interation ]

  triggers = {
    redeployment = sha1(jsonencode([
        aws_api_gateway_resource.order_api.id,
        aws_api_gateway_method.post.id,
        aws_api_gateway_integration.order_interation.id]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "order_stage" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name = var.stage_name
  deployment_id = aws_api_gateway_deployment.order_deployment.id
}

resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name = "API-Gateway-logs-${aws_api_gateway_rest_api.rest_api.id}/${var.stage_name}"
  retention_in_days = 7
}

resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.apigateway_order.arn
}
