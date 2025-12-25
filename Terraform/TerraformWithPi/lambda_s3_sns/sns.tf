# SNS Topic - Used to send email notifications when files are uploaded to S3
# SNS (Simple Notification Service) can send emails, SMS, or other notifications

# Create SNS Topic for S3 upload notifications
resource "aws_sns_topic" "s3_upload_notifications" {
  name = "${var.project_name}-s3-upload-notifications"
  
  tags = {
    Name    = "${var.project_name}-s3-notifications"
    Purpose = "Email notifications for S3 uploads"
  }
}

# Create Email Subscription to SNS Topic
# This will send emails to the specified address when messages are published to the topic
resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.s3_upload_notifications.arn
  protocol  = "email"                    # Send via email
  endpoint  = var.email                  # Email address from variables
  
  # Note: After deployment, you must confirm the subscription via email
}

# Output SNS Topic ARN for Lambda function to use
output "sns_topic_arn" {
  description = "ARN of SNS topic for Lambda to publish messages"
  value       = aws_sns_topic.s3_upload_notifications.arn
}