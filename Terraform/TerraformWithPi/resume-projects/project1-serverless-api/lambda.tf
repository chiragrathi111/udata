# Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          aws_dynamodb_table.orders.arn,
          "${aws_dynamodb_table.orders.arn}/index/*",
          aws_dynamodb_table.inventory.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.order_queue.arn
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.order_notifications.arn
      }
    ]
  })
}

# Lambda Function - Create Order
data "archive_file" "create_order" {
  type        = "zip"
  source_file = "${path.module}/lambda/create_order.py"
  output_path = "${path.module}/lambda/create_order.zip"
}

resource "aws_lambda_function" "create_order" {
  filename         = data.archive_file.create_order.output_path
  function_name    = "${var.project_name}-create-order"
  role            = aws_iam_role.lambda_role.arn
  handler         = "create_order.lambda_handler"
  source_code_hash = data.archive_file.create_order.output_base64sha256
  runtime         = "python3.11"
  timeout         = 30

  environment {
    variables = {
      ORDERS_TABLE     = aws_dynamodb_table.orders.name
      INVENTORY_TABLE  = aws_dynamodb_table.inventory.name
      ORDER_QUEUE_URL  = aws_sqs_queue.order_queue.url
    }
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_cloudwatch_log_group" "create_order" {
  name              = "/aws/lambda/${aws_lambda_function.create_order.function_name}"
  retention_in_days = 7
}

resource "aws_lambda_permission" "create_order" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_order.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ecommerce_api.execution_arn}/*/*"
}

# Lambda Function - Get Orders
data "archive_file" "get_orders" {
  type        = "zip"
  source_file = "${path.module}/lambda/get_orders.py"
  output_path = "${path.module}/lambda/get_orders.zip"
}

resource "aws_lambda_function" "get_orders" {
  filename         = data.archive_file.get_orders.output_path
  function_name    = "${var.project_name}-get-orders"
  role            = aws_iam_role.lambda_role.arn
  handler         = "get_orders.lambda_handler"
  source_code_hash = data.archive_file.get_orders.output_base64sha256
  runtime         = "python3.11"
  timeout         = 30

  environment {
    variables = {
      ORDERS_TABLE = aws_dynamodb_table.orders.name
    }
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_cloudwatch_log_group" "get_orders" {
  name              = "/aws/lambda/${aws_lambda_function.get_orders.function_name}"
  retention_in_days = 7
}

resource "aws_lambda_permission" "get_orders" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_orders.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ecommerce_api.execution_arn}/*/*"
}

# Lambda Function - Process Order
data "archive_file" "process_order" {
  type        = "zip"
  source_file = "${path.module}/lambda/process_order.py"
  output_path = "${path.module}/lambda/process_order.zip"
}

resource "aws_lambda_function" "process_order" {
  filename         = data.archive_file.process_order.output_path
  function_name    = "${var.project_name}-process-order"
  role            = aws_iam_role.lambda_role.arn
  handler         = "process_order.lambda_handler"
  source_code_hash = data.archive_file.process_order.output_base64sha256
  runtime         = "python3.11"
  timeout         = 60

  environment {
    variables = {
      ORDERS_TABLE    = aws_dynamodb_table.orders.name
      INVENTORY_TABLE = aws_dynamodb_table.inventory.name
      SNS_TOPIC_ARN   = aws_sns_topic.order_notifications.arn
    }
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_cloudwatch_log_group" "process_order" {
  name              = "/aws/lambda/${aws_lambda_function.process_order.function_name}"
  retention_in_days = 7
}

resource "aws_lambda_event_source_mapping" "process_order" {
  event_source_arn = aws_sqs_queue.order_queue.arn
  function_name    = aws_lambda_function.process_order.arn
  batch_size       = 10
  enabled          = true
}
