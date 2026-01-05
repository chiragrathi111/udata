# =============================================================================
# SNS MODULE OUTPUTS
# =============================================================================

output "topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.this.name
}

output "subscription_arn" {
  description = "ARN of the email subscription"
  value       = aws_sns_topic_subscription.email.arn
}