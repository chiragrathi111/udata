data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "student_management" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda_dynamodb_role.arn
  filename         = data.archive_file.lambda_function.output_path
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  handler          = "lambda_function.lambda_handler"  # The handler is the entry point of your Lambda function, in the format "file_name.function_name"
  runtime          = var.runtime
  timeout          = 30

  environment {
    variables = {
      STUDENTS_TABLE_NAME       = var.students_table_name
      STUDENT_ID_ATTRIBUTE_NAME = var.student_id_attribute_name
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_dynamodb_attachment]
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 7
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.student_management.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.student_api.execution_arn}/*/*"
}
