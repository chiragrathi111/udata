resource "aws_dynamodb_table" "students" {
  name         = var.students_table_name
  billing_mode = "PAY_PER_REQUEST"  # On-Demand billing mode
  hash_key     = var.student_id_attribute_name

  attribute {
    name = var.student_id_attribute_name
    type = "S"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
