variable "region" {
  type = string
  default = "us-east-1"
}

variable "students_table_name" {
  type = string
  default = "students"
}

variable "student_id_attribute_name" {
  type = string
  default = "studentId"
}

variable "environment" {
  type = string
  default = "Production"
}

variable "project_name" {
  type = string
  default = "StudentManagement"
}

variable "runtime" {
  type = string
  default = "python3.12"
}

variable "function_name" {
  type = string
  default = "student-management"
}