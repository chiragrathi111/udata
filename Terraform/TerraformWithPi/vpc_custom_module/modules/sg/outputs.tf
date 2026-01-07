output "security_group_id" {
  value = aws_security_group.this.id
}

# Output is very important, if you want to use the child module id like vpc_id, subnet_id etc in parent module so first define output in child module
#  and then call that output in parent module.
# Then only you can use that child module resource in parent module.