resource "random_password" "db_password" {
  special = true
  length  = 16
  override_special = "_%@#$"
}

resource "aws_secretsmanager_secret" "ssm" {
  name                    = "${var.environment}ssm-${random_password.db_password.id}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "ssm" {
  secret_id = aws_secretsmanager_secret.ssm.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "mysql"
    host = ""
  })
}