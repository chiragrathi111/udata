#!/bin/bash

# ============================================================
# EC2 Instance Stop/Start Script
#
# Usage:
#   ./ec2_control.sh start     → Start the instance
#   ./ec2_control.sh stop      → Stop the instance
#   ./ec2_control.sh status    → Check current status
#
# For cron job (auto schedule):
#   crontab -e
#   30 2 * * 1-5 /full/path/to/ec2_control.sh start   # 8 AM IST Mon-Fri
#   30 14 * * 1-5 /full/path/to/ec2_control.sh stop    # 8 PM IST Mon-Fri
# ============================================================

# ============================================================
# ⚠️  FILL THESE WITH YOUR VALUES
# ============================================================
INSTANCE_ID="i-09f77be5e1745e6c0"
REGION="ap-south-1"

# Uncomment these if running via cron (cron doesn't load your shell profile)
# export AWS_ACCESS_KEY_ID="AKIA_YOUR_KEY"
# export AWS_SECRET_ACCESS_KEY="YOUR_SECRET"

# ============================================================
# Script logic (don't change below)
# ============================================================
ACTION=$1
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

if [ -z "$ACTION" ]; then
    echo "Usage: $0 {start|stop|status}"
    echo ""
    echo "Examples:"
    echo "  $0 start    → Start EC2 instance"
    echo "  $0 stop     → Stop EC2 instance"
    echo "  $0 status   → Check instance status"
    exit 1
fi

case $ACTION in
    start)
        echo "[$TIMESTAMP] Starting instance $INSTANCE_ID..."
        aws ec2 start-instances \
            --instance-ids "$INSTANCE_ID" \
            --region "$REGION" \
            --output text

        echo "[$TIMESTAMP] Waiting for instance to be running..."
        aws ec2 wait instance-running \
            --instance-ids "$INSTANCE_ID" \
            --region "$REGION"

        # Get public IP after start
        PUBLIC_IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --region "$REGION" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)

        echo "[$TIMESTAMP] ✅ Instance $INSTANCE_ID is now RUNNING"
        echo "[$TIMESTAMP] Public IP: $PUBLIC_IP"
        ;;

    stop)
        echo "[$TIMESTAMP] Stopping instance $INSTANCE_ID..."
        aws ec2 stop-instances \
            --instance-ids "$INSTANCE_ID" \
            --region "$REGION" \
            --output text

        echo "[$TIMESTAMP] Waiting for instance to be stopped..."
        aws ec2 wait instance-stopped \
            --instance-ids "$INSTANCE_ID" \
            --region "$REGION"

        echo "[$TIMESTAMP] 🛑 Instance $INSTANCE_ID is now STOPPED"
        ;;

    status)
        STATE=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --region "$REGION" \
            --query 'Reservations[0].Instances[0].State.Name' \
            --output text)

        PUBLIC_IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --region "$REGION" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)

        INSTANCE_TYPE=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --region "$REGION" \
            --query 'Reservations[0].Instances[0].InstanceType' \
            --output text)

        echo "================================"
        echo "  Instance:  $INSTANCE_ID"
        echo "  Type:      $INSTANCE_TYPE"
        echo "  State:     $STATE"
        echo "  Public IP: $PUBLIC_IP"
        echo "  Region:    $REGION"
        echo "================================"
        ;;

    *)
        echo "❌ Unknown action: $ACTION"
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac
