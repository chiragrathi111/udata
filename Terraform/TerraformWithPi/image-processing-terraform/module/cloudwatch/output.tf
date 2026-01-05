# =============================================================================
# CLOUDWATCH MODULE OUTPUTS
# =============================================================================

output "dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.id}#dashboards:name=${aws_cloudwatch_dashboard.image_processing.dashboard_name}"
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.image_processing.dashboard_name
}

output "alarm_names" {
  description = "Names of created CloudWatch alarms"
  value = {
    critical_errors    = aws_cloudwatch_metric_alarm.critical_errors.alarm_name
    processing_success = aws_cloudwatch_metric_alarm.processing_success.alarm_name
    lambda_duration    = aws_cloudwatch_metric_alarm.lambda_duration.alarm_name
    lambda_throttles   = aws_cloudwatch_metric_alarm.lambda_throttles.alarm_name
  }
}