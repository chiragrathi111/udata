output "instance_id" {
  description = "EC2 Instance ID"
  value       = var.instance_id
}

output "instance_type" {
  description = "Instance type (e.g., t2.micro)"
  value       = data.aws_instance.target.instance_type
}

output "current_state" {
  description = "Current state of the instance"
  value       = aws_ec2_instance_state.this.state
}

output "private_ip" {
  description = "Private IP address"
  value       = data.aws_instance.target.private_ip
}

output "public_ip" {
  description = "Public IP address (empty when stopped)"
  value       = data.aws_instance.target.public_ip
}

output "status_message" {
  description = "Human-readable status"
  value       = var.instance_running ? "✅ Instance is RUNNING" : "🛑 Instance is STOPPED"
}
