#!/bin/bash

# Simple EC2 Start/Stop - Just run it, it will ask you everything

REGION="ap-south-1"

read -p "Enter Instance ID: " ID
echo ""
echo "What do you want to do?"
echo "  1) Start"
echo "  2) Stop"
echo "  3) Status"
echo ""
read -p "Enter choice (1/2/3): " CHOICE

echo ""

case $CHOICE in
    1)
        echo "🚀 Starting $ID..."
        aws ec2 start-instances --instance-ids "$ID" --region "$REGION" --output text
        aws ec2 wait instance-running --instance-ids "$ID" --region "$REGION"
        echo "✅ $ID is now RUNNING"
        ;;
    2)
        echo "🛑 Stopping $ID..."
        aws ec2 stop-instances --instance-ids "$ID" --region "$REGION" --output text
        aws ec2 wait instance-stopped --instance-ids "$ID" --region "$REGION"
        echo "✅ $ID is now STOPPED"
        ;;
    3)
        aws ec2 describe-instances --instance-ids "$ID" --region "$REGION" \
            --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress,InstanceType]' \
            --output table
        ;;
    *)
        echo "❌ Invalid choice"
        ;;
esac
