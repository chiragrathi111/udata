output "api_base_url" {
  description = "API Gateway base URL"
  value       = aws_api_gateway_stage.student_api.invoke_url
}

output "api_students_url" {
  description = "Full URL for /students endpoint - USE THIS IN POSTMAN"
  value       = "${aws_api_gateway_stage.student_api.invoke_url}/students"
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.students.name
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.student_management.function_name
}

output "postman_test_commands" {
  description = "Postman/curl test commands"
  value       = <<-EOT

    ========== YOUR API URL ==========
    ${aws_api_gateway_stage.student_api.invoke_url}/students

    ========== POSTMAN TESTS ==========

    1. CREATE Student (POST):
       URL: ${aws_api_gateway_stage.student_api.invoke_url}/students
       Method: POST
       Body (raw JSON):
       {
         "name": "Chirag Rathi",
         "email": "chirag@example.com",
         "course": "AWS DevOps",
         "marks": 95
       }

    2. GET All Students (GET):
       URL: ${aws_api_gateway_stage.student_api.invoke_url}/students
       Method: GET

    3. GET Single Student (GET):
       URL: ${aws_api_gateway_stage.student_api.invoke_url}/students?studentId=<paste-id-here>
       Method: GET

    4. UPDATE Student (PUT):
       URL: ${aws_api_gateway_stage.student_api.invoke_url}/students
       Method: PUT
       Body (raw JSON):
       {
         "studentId": "<paste-id-here>",
         "name": "Chirag Rathi Updated",
         "email": "chirag.updated@example.com",
         "course": "AWS Solutions Architect",
         "marks": 99
       }

    5. DELETE Student (DELETE):
       URL: ${aws_api_gateway_stage.student_api.invoke_url}/students?studentId=<paste-id-here>
       Method: DELETE

  EOT
}
