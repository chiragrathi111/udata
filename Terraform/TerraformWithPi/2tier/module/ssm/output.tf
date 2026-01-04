output "db_password" {
  description = "Database password from random password generator"
  value       = random_password.db_password.result
  sensitive   = true
}