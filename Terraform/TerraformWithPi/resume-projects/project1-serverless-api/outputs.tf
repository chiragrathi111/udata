output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = "${aws_api_gateway_stage.api.invoke_url}/orders"
}

output "orders_table_name" {
  description = "DynamoDB Orders table name"
  value       = aws_dynamodb_table.orders.name
}

output "inventory_table_name" {
  description = "DynamoDB Inventory table name"
  value       = aws_dynamodb_table.inventory.name
}

output "order_queue_url" {
  description = "SQS Order Queue URL"
  value       = aws_sqs_queue.order_queue.url
}

output "test_commands" {
  description = "Commands to test the API"
  value       = <<-EOT
    # Create Order
    curl -X POST ${aws_api_gateway_stage.api.invoke_url}/orders \
      -H "Content-Type: application/json" \
      -d '{
        "customerId": "CUST001",
        "items": [
          {"productId": "PROD001", "quantity": 2, "price": 29.99}
        ],
        "totalAmount": 59.98
      }'
    
    # Get Orders
    curl ${aws_api_gateway_stage.api.invoke_url}/orders
    
    # Add Inventory (via AWS CLI)
    aws dynamodb put-item \
      --table-name ${aws_dynamodb_table.inventory.name} \
      --item '{
        "productId": {"S": "PROD001"},
        "name": {"S": "Product 1"},
        "stock": {"N": "100"},
        "price": {"N": "29.99"}
      }'
  EOT
}
