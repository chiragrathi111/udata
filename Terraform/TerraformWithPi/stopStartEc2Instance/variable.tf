# ============================================================
# AWS Credentials (stored in terraform.tfvars, NEVER in code)
# ============================================================
variable "access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true # Terraform will hide this in logs/output
}

variable "secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true # Terraform will hide this in logs/output
}

variable "region" {
  description = "AWS region where your EC2 instance is running"
  type        = string
  default     = "us-east-1"
}

# ============================================================
# EC2 Instance Configuration
# ============================================================
variable "instance_id" {
  description = "EC2 Instance ID to stop/start (e.g., i-0abc123def456)"
  type        = string

  validation {
    condition     = can(regex("^i-[a-z0-9]{8,17}$", var.instance_id))
    error_message = "Instance ID must start with 'i-' followed by 8-17 hex characters."
  }
}

# ============================================================
# THE MAIN SWITCH - true = running, false = stopped
# ============================================================
variable "instance_running" {
  description = "true = START the instance, false = STOP the instance"
  type        = bool
  default     = true
}
