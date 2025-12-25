# Archive Lambda function code into ZIP file
# Terraform creates ZIP from your Python source code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/hello.py"     # FIXED: Use existing hello.py file
  output_path = "${path.module}/lambda/hello.zip"    # Output ZIP file
}

# Lambda Function for API Gateway
# This function will be triggered by API Gateway requests
resource "aws_lambda_function" "lambda_apigw" {
  function_name    = "${var.project_name}-lambda-apigw"  # FIXED: Use var.project_name
  filename         = data.archive_file.lambda_zip.output_path
  handler          = "hello.lambda_handler"              # FIXED: Match actual file name
  runtime          = "python3.10"
  timeout          = 30
  role            = aws_iam_role.lambda_apigw_role.arn   # FIXED: Match IAM role name
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  tags = {
    Name    = "${var.project_name}-lambda-apigw"
    Purpose = "Lambda function for API Gateway integration"
  }
}

# CloudWatch Log Group for Lambda function logs
# Lambda automatically writes logs here for debugging
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_apigw.function_name}"
  retention_in_days = 7  # Keep logs for 7 days
  
  tags = {
    Name    = "${var.project_name}-lambda-logs"
    Purpose = "Lambda function logs for API Gateway"
  }
}