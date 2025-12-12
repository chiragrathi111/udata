# Terraform Expressions -

# 1. Conditional expressions:-
# Conditional expressions are used to evaluate a condition and return one of two values based on the result of the evaluation.
# Syntax: condition ? true_value : false_value
# instance_type = var.is_production ? "t2.large" : "t2.micro"
# Example: 
variable "is_active" {
  type = bool
  default = true
}

# == ========================================================================================================

# 2. Dynamic Blocks:-
# Dynamic blocks are used to generate multiple nested blocks within a resource or module based on a collection.
# Syntax:
# dynamic "block_name" {
#   for_each = collection
#   content {
#     attribute = block_value
#   }
# }
# Example:
variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

# Another Example of dynamic block
variable port {
    type = list(number)
}
# port = [22,80,443]

resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Example security group"

  dynamic "ingress" {
    for_each = var.port
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

# If We using dynamic block and teir ave list of object so that place content usin this thing
# form_port = ingress.value.from_port
# to_port = ingress.value.to_port
# protocol = ingress.value.protocol
# cidr_blocks = ingress.value.cidr_blocks


# ========================================================================================================

# 3. Splat Expressions:-
# Splat expressions are used to extract multiple values from a list of objects or resources.
# Syntax: resource_type.resource_name[*].attribute
# Example:
resource "aws_instance" "example" {
  count         = 3
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

output "instance_ids" {
  value = aws_instance.example[*].id
}
# This will output a list of instance IDs for all instances created by the aws_instance.example resource
# If we are using * then it will ave all the value in list form
