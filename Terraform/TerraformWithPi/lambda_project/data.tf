# Archive Lambda function code into ZIP file
# Terraform will create a ZIP file from your Python code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/lambda_function.py"  # Path to your Python file
  output_path = "${path.module}/lambda_function.zip"           # ZIP file Terraform creates
}

