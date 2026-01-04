resource "aws_db_subnet_group" "main" {
  name       = "mysql-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "mysql-db-subnet-group"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "main" {
  identifier             = "mysql-db"
  allocated_storage      = var.allocated_storage
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  publicly_accessible    = false

  tags = {
    Name        = "mysql-rds"
  }
}