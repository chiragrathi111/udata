# # Create A Web Ec2 Instance
 resource "aws_instance" "cr1" {
   ami           = var.ami_id
   instance_type = var.instance_type
   subnet_id     = aws_subnet.public_cr1.id
   associate_public_ip_address = true
   vpc_security_group_ids = [aws_security_group.albb_sg.id]
   key_name = var.key_name

#   #Added User Data
#   user_data     = file("${path.module}/userdata.sh")

   tags = {
     Name = "Web Server 1"
   }
}

# Create A Private Ec2 Instance
 resource "aws_instance" "crr" {
   ami           = var.ami_id
   instance_type = var.instance_type
   subnet_id     = aws_subnet.private_cr1.id
   associate_public_ip_address = false
   vpc_security_group_ids = [aws_security_group.albb_sg.id]
   key_name = var.key_name

#   #Added User Data
#   user_data     = file("${path.module}/userdata.sh")

   tags = {
     Name = "Private Web Server 1"
   }
}