# Quick Connectivity Test Commands

# Run these commands to check the current status:

## 1. Check if TGW routes exist in VPC route tables
terraform state list | grep aws_route

## 2. Check TGW peering status
terraform output

## 3. Apply security group changes
terraform apply -target=aws_security_group.sg_vpc1 -target=aws_security_group.sg_vpc2 -target=aws_security_group.sg_vpc3

## 4. If routes are missing, force recreate them
terraform apply -target=aws_route.vpc1_to_vpc2 -target=aws_route.vpc1_to_vpc3 -target=aws_route.vpc2_to_vpc1 -target=aws_route.vpc2_to_vpc3 -target=aws_route.vpc3_to_vpc1 -target=aws_route.vpc3_to_vpc2

## 5. Check route table in AWS Console
# Go to VPC Console → Route Tables → Check if TGW routes are present

## 6. Test connectivity from EC2 instances
# SSH to VPC1 instance and run:
# ping 13.0.1.x (VPC2 private IP)
# ping 14.0.1.x (VPC3 private IP)

## Common Issues:
# 1. TGW peering not accepted - check peering status
# 2. Routes not created due to dependency issues
# 3. Security groups blocking ICMP traffic
# 4. TGW attachments not in 'available' state