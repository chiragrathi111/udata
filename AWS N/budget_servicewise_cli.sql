aws budgets create-budget \
  --account-id 174826642792 \
  --budget '{
    "BudgetName": "BedrockBudgetCR",
    "BudgetLimit": { "Amount": "50", "Unit": "USD" },
    "CostFilters": { "Service": ["Amazon Bedrock"] },
    "CostTypes": { "IncludeTax": true, "IncludeSubscription": true },
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST"
  }' \
  --notifications-with-subscribers '[
    {
      "Notification": {
        "NotificationType": "ACTUAL",
        "ComparisonOperator": "GREATER_THAN",
        "Threshold": 80,
        "ThresholdType": "PERCENTAGE"
      },
      "Subscribers": [
        { "SubscriptionType": "EMAIL", "Address": "chirag@pipra.solutions" },
        { "SubscriptionType": "EMAIL", "Address": "sandeepan@pipra.solutions" },
        { "SubscriptionType": "EMAIL", "Address": "ashish@pipra.solutions" }
      ]
    }
  ]'

