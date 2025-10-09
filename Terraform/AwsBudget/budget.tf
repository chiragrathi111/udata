resource "aws_budgets_budget" "cost" {
  name        = "Monthly Cost Budget"
  budget_type = "COST"
  limit_amount = var.cost_budget_limit_amount
  limit_unit  = "USD"
  time_unit   = "MONTHLY"

  # Actual cost notification
  notification {
    comparison_operator = "GREATER_THAN"
    threshold          = 90
    threshold_type     = "PERCENTAGE"
    notification_type  = "ACTUAL"
    subscriber_email_addresses = var.notification_emails
  }

  cost_types {
    include_recurring = true
  }
}