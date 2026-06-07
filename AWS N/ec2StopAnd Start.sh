#!/bin/bash

# ---------------------------------------
# AWS EC2 Instance Manager
# ---------------------------------------

clear

echo "======================================="
echo "      AWS EC2 Instance Manager"
echo "======================================="

# ---------------------------------------
# Enter Region
# ---------------------------------------

read -p "Enter AWS Region (example: ap-south-1): " REGION

export AWS_DEFAULT_REGION=$REGION

echo ""
echo "Fetching EC2 instances..."
echo ""

# ---------------------------------------
# Show Instances
# ---------------------------------------

aws ec2 describe-instances \
--query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`]|[0].Value]' \
--output table

echo ""
echo "======================================="
echo "Choose Operation"
echo "1. Start Instance"
echo "2. Stop Instance"
echo "3. Check Status"
echo "4. Reboot Instance"
echo "======================================="

read -p "Enter choice: " CHOICE

echo ""
read -p "Enter Instance ID: " INSTANCE_ID

echo ""

# ---------------------------------------
# Perform Action
# ---------------------------------------

case $CHOICE in

1)
    echo "Starting instance..."
    aws ec2 start-instances --instance-ids $INSTANCE_ID
    ;;

2)
    echo "Stopping instance..."
    aws ec2 stop-instances --instance-ids $INSTANCE_ID
    ;;

3)
    echo "Checking instance status..."
    
    aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' \
    --output table
    ;;

4)
    echo "Rebooting instance..."
    aws ec2 reboot-instances --instance-ids $INSTANCE_ID
    ;;

*)
    echo "Invalid choice"
    ;;
esac

echo ""
echo "Done."