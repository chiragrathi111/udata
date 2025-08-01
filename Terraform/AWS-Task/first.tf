# resource "aws_key_pair" "deployer" {
#   key_name   = "deployer-key"
#   public_key = file("${path.module}id_rsac.pub")
# }

#if you want create a multiple security group run a single dynamic command then your code is 
#short and usefull

# resource "aws_security_group" "new-sg" {
#   name        = "new-sg"
#   description = "new-sg"

#   dynamic "ingress" {
#     for_each = [22, 80, 443, 5432, 8443]
#     iterator = port
#     content {
#       from_port   = port.value
#       to_port     = port.value
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   }
# }