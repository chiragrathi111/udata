resource "aws_dynamodb_table" "students" {
  name           = var.student_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = var.student_attribute_name

  attribute {
    name = var.student_attribute_name
    type = "S"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
  
}