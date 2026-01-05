# =============================================================================
# CLOUDWATCH MODULE - Monitoring, alerting, and log analysis
# =============================================================================
# This module creates CloudWatch alarms, metric filters, and dashboards
# for monitoring the image processing pipeline
# =============================================================================

# Log metric filter for ERROR messages
resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "${var.project_name}-lambda-errors"
  log_group_name = "/aws/lambda/${var.lambda_function_name}"
  pattern        = "ERROR"

  metric_transformation {
    name      = "ErrorCount"
    namespace = "ImageProcessing"
    value     = "1"
  }
}

# Log metric filter for successful processing
resource "aws_cloudwatch_log_metric_filter" "success_filter" {
  name           = "${var.project_name}-lambda-success"
  log_group_name = "/aws/lambda/${var.lambda_function_name}"
  pattern        = "Successfully processed"

  metric_transformation {
    name      = "SuccessCount"
    namespace = "ImageProcessing"
    value     = "1"
  }
}

# Critical alarm for errors
resource "aws_cloudwatch_metric_alarm" "critical_errors" {
  alarm_name          = "${var.project_name}-critical-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ErrorCount"
  namespace           = "ImageProcessing"
  period              = 300  # 5 minutes
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Critical: Lambda function encountered errors"
  alarm_actions       = [var.critical_sns_arn]
  ok_actions          = [var.normal_sns_arn]
  
  tags = var.tags
}

# Normal alarm for successful processing
resource "aws_cloudwatch_metric_alarm" "processing_success" {
  alarm_name          = "${var.project_name}-processing-success"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "SuccessCount"
  namespace           = "ImageProcessing"
  period              = 300  # 5 minutes
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Normal: Images processed successfully"
  alarm_actions       = [var.normal_sns_arn]
  
  tags = var.tags
}

# Lambda duration alarm
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.project_name}-lambda-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Average"
  threshold           = 240000  # 4 minutes (240 seconds * 1000 ms)
  alarm_description   = "Warning: Lambda function taking too long"
  alarm_actions       = [var.critical_sns_arn]
  
  dimensions = {
    FunctionName = var.lambda_function_name
  }
  
  tags = var.tags
}

# Lambda throttles alarm
resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${var.project_name}-lambda-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Critical: Lambda function is being throttled"
  alarm_actions       = [var.critical_sns_arn]
  
  dimensions = {
    FunctionName = var.lambda_function_name
  }
  
  tags = var.tags
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "image_processing" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["ImageProcessing", "SuccessCount"],
            ["ImageProcessing", "ErrorCount"],
            ["ImageProcessing", "ImagesProcessed"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.id
          title   = "Image Processing Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", var.lambda_function_name],
            ["AWS/Lambda", "Invocations", "FunctionName", var.lambda_function_name],
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_name],
            ["AWS/Lambda", "Throttles", "FunctionName", var.lambda_function_name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.id
          title   = "Lambda Function Metrics"
          period  = 300
        }
      }
    ]
  })
}

# Data source for current region
data "aws_region" "current" {}
