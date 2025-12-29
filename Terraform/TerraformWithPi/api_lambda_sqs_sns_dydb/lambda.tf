data "archive_file" "lambda_producer" {
  type = "zip"
  source_file =  "${path.module}/lambda_producer.py"
  output_path = "${path.module}/lambda_producer.zip"
}

resource "aws_lambda_function" "lambda_producer" {
  function_name = "${var.project_name}_lambda_producer"
  filename = data.archive_file.lambda_producer.output_path
  source_code_hash = data.archive_file.lambda_producer.output_base64sha256
  role = aws_iam_role.lambda_role.arn
  handler = "lambda_producer.lambda_handler"
  runtime = "python3.10"
  timeout = 60
  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.order_queue.url
    }
  }
}

resource "aws_lambda_permission" "lambda_producer_permission" {
  function_name = aws_lambda_function.lambda_producer.function_name
  principal = "apigateway.amazonaws.com"
  action = "lambda:InvokeFunction"
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
  depends_on = [aws_api_gateway_rest_api.rest_api]
  
}

data "archive_file" "lambda_consumer" {
  type = "zip"
  source_file =  "${path.module}/lambda_consumer.py"
  output_path = "${path.module}/lambda_consumer.zip"
}

resource "aws_lambda_function" "lambda_consumer" {
  function_name = "${var.project_name}_lambda_consumer"
  filename = data.archive_file.lambda_consumer.output_path
  source_code_hash = data.archive_file.lambda_consumer.output_base64sha256
  role = aws_iam_role.lambda_role.arn
  handler = "lambda_consumer.lambda_handler"
  runtime = "python3.10"
  timeout = 30  # Reduced to match SQS visibility timeout

  environment {
    variables = {
      TABLE = aws_dynamodb_table.orders.name
      AWS_SNS_ARN = aws_sns_topic.order_topic.arn
    }
  }
}

resource "aws_lambda_permission" "lambda_consumer_permission" {
  function_name = aws_lambda_function.lambda_consumer.function_name
  principal = "sqs.amazonaws.com"
  action = "lambda:InvokeFunction"
  source_arn = aws_sqs_queue.order_queue.arn
}

# Event Source Mapping - Connects SQS queue to Lambda consumer
# This tells AWS to automatically invoke Lambda when messages arrive in SQS
resource "aws_lambda_event_source_mapping" "sqs_lambda_trigger" {
  event_source_arn = aws_sqs_queue.order_queue.arn
  function_name    = aws_lambda_function.lambda_consumer.arn
  batch_size       = 1  # Process 1 message at a time
  enabled          = true
}