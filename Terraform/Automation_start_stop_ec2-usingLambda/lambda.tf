# Package the Python script into a ZIP file
# Lambda requires code to be uploaded as a ZIP archive
# archive_file recreates the ZIP automatically when the .py file changes
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function/start_ec2.py"
  output_path = "${path.module}/lambda_function/start_ec2.zip" # zip is generated at plan/apply time
}

# Lambda function resource
resource "aws_lambda_function" "start_ec2" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "start-ec2-weekdays-9am-ist"
  role          = aws_iam_role.lambda_ec2_role.arn # IAM role defined in main.tf

  # handler = "filename_without_extension.function_name_in_python"
  handler = "start_ec2.lambda_handler"

  # python3.12 is current LTS runtime for Lambda
  runtime = "python3.12"

  # source_code_hash triggers a re-deploy when the ZIP content changes
  # Without this, Terraform won't redeploy even if code changed
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Empty string forces Terraform to actively REMOVE any CMK set manually in the console
  # Without this explicit "", Terraform ignores the drift and the old CMK stays attached
  # AWS-managed encryption still applies — env vars are not plain text
  kms_key_arn = ""

  # Default Lambda timeout is 3 seconds — too short for EC2 API calls
  # EC2 start_instances can take 5-15 seconds on first call (cold start + API latency)
  # 30 seconds is safe and well within Lambda's 15-minute max
  timeout = 30

  # Environment variables passed into the Lambda runtime
  # The Python code reads INSTANCE_IDS via os.environ['INSTANCE_IDS']
  # This way instance IDs are never hardcoded in source code
  environment {
    variables = {
      # join() converts the list to a comma-separated string: "i-aaa,i-bbb"
      # Lambda env vars must be strings — the Python code splits this back into a list
      INSTANCE_IDS = join(",", var.instance_id)
    }
  }
}

# ── STOP FUNCTION ─────────────────────────────────────────────────────────────

# Package stop_ec2.py into its own ZIP
data "archive_file" "stop_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function/stop_ec2.py"
  output_path = "${path.module}/lambda_function/stop_ec2.zip"
}

# Lambda function that stops EC2 instances (triggered Mon-Fri 7 PM IST)
resource "aws_lambda_function" "stop_ec2" {
  filename      = data.archive_file.stop_lambda_zip.output_path
  function_name = "stop-ec2-weekdays-7pm-ist"
  role          = aws_iam_role.lambda_ec2_role.arn # reuse same IAM role — already has ec2:StopInstances

  handler          = "stop_ec2.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.stop_lambda_zip.output_base64sha256

  # Explicitly empty to prevent CMK being attached manually in console
  # (same fix applied after KMS error on the start function — see README troubleshooting)
  kms_key_arn = ""

  timeout = 30

  environment {
    variables = {
      INSTANCE_IDS = join(",", var.instance_id)
    }
  }
}
