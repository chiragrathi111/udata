# ============================================================
# Read your EXISTING EC2 instance (we don't create a new one)
# This just fetches info about the instance you gave us
# ============================================================
data "aws_instance" "target" {
  instance_id = var.instance_id
}

# ============================================================
# THIS IS THE MAGIC - Controls EC2 instance state
#
# instance_running = true  → state = "running"  → START
# instance_running = false → state = "stopped"   → STOP
#
# How to use:
#   1. Set instance_running = false in terraform.tfvars
#   2. Run: terraform apply
#   3. Instance stops!
#
#   4. Set instance_running = true in terraform.tfvars
#   5. Run: terraform apply
#   6. Instance starts!
# ============================================================
resource "aws_ec2_instance_state" "this" {
  instance_id = var.instance_id
  state       = var.instance_running ? "running" : "stopped"
}
