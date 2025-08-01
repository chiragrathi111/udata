variable access_key {
    type = string
}

variable secret_key {
    type = string
}

variable region {
    type = string
}

variable "cost_budget_limit_amount" {
  description = "The budget limit amount in USD"
  type        = number
}

variable "notification_emails" {
  description = "List of email addresses to notify"
  type        = list(string)
}