# =============================================================================
# VARIABLES - Input Configuration
# =============================================================================

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
  
  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-'."
  }
}

variable "my_ip" {
  description = "Your public IP address in CIDR notation (e.g., 203.0.113.0/32)"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.my_ip, 0))
    error_message = "Must be a valid CIDR block (e.g., 203.0.113.0/32)."
  }
}

variable "cluster_name" {
  description = "Name of the cluster (used for tagging)"
  type        = string
  default     = "k8s-cluster"
}