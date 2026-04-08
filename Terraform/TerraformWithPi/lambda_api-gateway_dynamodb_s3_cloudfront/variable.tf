variable "region" {
  type = string
  default = "us-east-1"
}

variable "student_table_name" {
  type = string
  default = "students"
}

variable "student_attribute_name" {
  type = string
  default = "studentId"
}

variable "function_name" {
  type = string
  default = "StudentManagementFunction"
}

variable "runtime" {
  type = string
  default = "python3.12"
}

variable "project_name" {
  type = string
  default = "Student-Management"
}

variable "environment" {
  type = string
  default = "prod"
}