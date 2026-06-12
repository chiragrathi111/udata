# AWS region where all resources (Lambda, EventBridge, IAM) will be created
variable "region" {
  type    = string
  default = "ap-south-2" # ap-south-2 = Hyderabad (closest for IST users)
}

# EC2 instance IDs to start on schedule — supports one or more instances
# Do NOT set a default here — force the user to pass it explicitly
# How to pass one:   export TF_VAR_instance_id='["i-0abc123def456"]'
# How to pass many:  export TF_VAR_instance_id='["i-0abc123def456","i-0xyz789ghi012"]'
# This way instance IDs never get committed to code or tfvars
variable "instance_id" {
  type        = list(string)
  description = "One or more EC2 instance IDs to start every Monday- Friday at 9 AM Start IST and at 7 PM Stop IST. Pass via: export TF_VAR_instance_id='[\"i-xxx\",\"i-yyy\"]'"
}
