resource "aws_sns_topic" "order_topic" {
  name = "order-topic"
}

resource "aws_sns_topic_subscription" "order_subscription" {
  topic_arn = aws_sns_topic.order_topic.arn
  protocol = "email"
  endpoint = var.email
}

# Output SNS Topic ARN for Lambda function to use
output "sns_topic_arn" {
  value = aws_sns_topic.order_topic.arn
}