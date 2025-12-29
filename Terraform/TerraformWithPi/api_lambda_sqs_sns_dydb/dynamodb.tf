resource "aws_dynamodb_table" "orders" {
    name = "Orders"
    hash_key = "OrderId"
    billing_mode = "PAY_PER_REQUEST"

    attribute {
      name = "OrderId"
      type = "S"
    }
}