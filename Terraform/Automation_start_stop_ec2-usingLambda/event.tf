# EventBridge (CloudWatch Events) rule — defines the schedule
# Schedule: Every weekday (Mon–Fri) at 9:00 AM IST
# IST = UTC+5:30, so 9:00 AM IST = 3:30 AM UTC
# Cron format: cron(Minutes Hours Day-of-month Month Day-of-week Year)
#   30      = minute 30
#   3       = hour 3 (AM UTC)
#   ?       = no specific day-of-month (required when day-of-week is set)
#   *       = every month
#   MON-FRI = Monday through Friday (weekdays only, skips Sat & Sun)
#   *       = every year
resource "aws_cloudwatch_event_rule" "start_ec2_weekdays" {
  name                = "start-ec2-weekdays-0900am-ist"
  description         = "Triggers Lambda every weekday (Mon-Fri) at 09:00 AM IST (3:30 AM UTC) to start EC2"
  schedule_expression = "cron(30 3 ? * MON-FRI *)"
}

# EventBridge target — links the rule to the Lambda function
# Without this, the rule fires but does nothing
resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.start_ec2_weekdays.name
  target_id = "StartEC2LambdaTarget"
  arn       = aws_lambda_function.start_ec2.arn
}

# Lambda resource-based policy — allows EventBridge to invoke the START Lambda
# Lambda has two types of permissions:
#   1. Execution role (main.tf)  — what Lambda can DO (call EC2, write logs)
#   2. Resource policy (this)    — who can CALL Lambda (EventBridge in this case)
# Without this, EventBridge gets "Access Denied" when trying to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge_start" {
  statement_id  = "AllowEventBridgeInvokeStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_ec2_weekdays.arn
}

# ── STOP SCHEDULE ─────────────────────────────────────────────────────────────

# EventBridge rule — fires every weekday at 7:00 PM IST
# IST = UTC+5:30, so 7:00 PM IST = 1:30 PM UTC
# Cron format: cron(Minutes Hours Day-of-month Month Day-of-week Year)
#   30      = minute 30
#   13      = hour 13 (1 PM UTC = 7 PM IST)
#   ?       = no specific day-of-month (required when day-of-week is set)
#   *       = every month
#   MON-FRI = Monday through Friday (weekdays only, skips Sat & Sun)
#   *       = every year
resource "aws_cloudwatch_event_rule" "stop_ec2_weekdays" {
  name                = "stop-ec2-weekdays-0700pm-ist"
  description         = "Triggers Lambda every weekday (Mon-Fri) at 07:00 PM IST (1:30 PM UTC) to stop EC2"
  schedule_expression = "cron(30 13 ? * MON-FRI *)"
}

# Link the stop rule to the stop Lambda
resource "aws_cloudwatch_event_target" "invoke_stop_lambda" {
  rule      = aws_cloudwatch_event_rule.stop_ec2_weekdays.name
  target_id = "StopEC2LambdaTarget"
  arn       = aws_lambda_function.stop_ec2.arn
}

# Allow EventBridge to invoke the stop Lambda
# Each Lambda function needs its own resource-based policy — the start permission above
# does not cover the stop function even though it is in the same account
resource "aws_lambda_permission" "allow_eventbridge_stop" {
  statement_id  = "AllowEventBridgeInvokeStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_ec2_weekdays.arn
}
