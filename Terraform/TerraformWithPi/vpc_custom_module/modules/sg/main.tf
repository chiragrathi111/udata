resource "aws_security_group" "this" {
  vpc_id = var.vpc_id
  description = "Security group for EC2 instances"

    dynamic "ingress" {
      for_each = var.port_no
      content {
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}