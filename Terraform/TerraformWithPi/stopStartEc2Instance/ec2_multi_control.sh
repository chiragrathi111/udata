#!/bin/bash

# ============================================================
# EC2 Multi-Instance Stop/Start/Status Script
#
# Usage:
#   ./ec2_multi_control.sh start i-0abc123 i-0def456 i-0ghi789
#   ./ec2_multi_control.sh stop  i-0abc123 i-0def456
#   ./ec2_multi_control.sh status i-0abc123 i-0def456 i-0ghi789
#
# You can pass 1 or 100 instance IDs — all handled!
# ============================================================

REGION="ap-south-1"

# Uncomment for cron job
# export AWS_ACCESS_KEY_ID="AKIA_YOUR_KEY"
# export AWS_SECRET_ACCESS_KEY="YOUR_SECRET"

# ============================================================
ACTION=$1
shift  # Remove first argument (action), rest are instance IDs
INSTANCE_IDS=("$@")
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

if [ -z "$ACTION" ] || [ ${#INSTANCE_IDS[@]} -eq 0 ]; then
    echo "Usage: $0 {start|stop|status} INSTANCE_ID_1 [INSTANCE_ID_2] [INSTANCE_ID_3] ..."
    echo ""
    echo "Examples:"
    echo "  $0 start  i-0abc123"
    echo "  $0 stop   i-0abc123 i-0def456 i-0ghi789"
    echo "  $0 status i-0abc123 i-0def456"
    exit 1
fi

echo "[$TIMESTAMP] Action: $ACTION | Instances: ${INSTANCE_IDS[*]} | Region: $REGION"
echo ""

case $ACTION in
    start)
        echo "🚀 Starting ${#INSTANCE_IDS[@]} instance(s)..."
        aws ec2 start-instances \
            --instance-ids "${INSTANCE_IDS[@]}" \
            --region "$REGION" \
            --output text

        echo ""
        echo "⏳ Waiting for all instances to be running..."
        aws ec2 wait instance-running \
            --instance-ids "${INSTANCE_IDS[@]}" \
            --region "$REGION"

        echo ""
        echo "✅ All instances RUNNING:"
        for ID in "${INSTANCE_IDS[@]}"; do
            IP=$(aws ec2 describe-instances \
                --instance-ids "$ID" \
                --region "$REGION" \
                --query 'Reservations[0].Instances[0].PublicIpAddress' \
                --output text)
            echo "   $ID → Public IP: $IP"
        done
        ;;

    stop)
        echo "🛑 Stopping ${#INSTANCE_IDS[@]} instance(s)..."
        aws ec2 stop-instances \
            --instance-ids "${INSTANCE_IDS[@]}" \
            --region "$REGION" \
            --output text

        echo ""
        echo "⏳ Waiting for all instances to be stopped..."
        aws ec2 wait instance-stopped \
            --instance-ids "${INSTANCE_IDS[@]}" \
            --region "$REGION"

        echo ""
        echo "🛑 All instances STOPPED"
        for ID in "${INSTANCE_IDS[@]}"; do
            echo "   $ID → stopped"
        done
        ;;

    status)
        echo "📊 Status of ${#INSTANCE_IDS[@]} instance(s):"
        echo "================================================================"
        printf "%-22s %-12s %-16s %-12s\n" "INSTANCE ID" "STATE" "PUBLIC IP" "TYPE"
        echo "----------------------------------------------------------------"
        for ID in "${INSTANCE_IDS[@]}"; do
            INFO=$(aws ec2 describe-instances \
                --instance-ids "$ID" \
                --region "$REGION" \
                --query 'Reservations[0].Instances[0].[State.Name,PublicIpAddress,InstanceType]' \
                --output text)
            STATE=$(echo "$INFO" | awk '{print $1}')
            IP=$(echo "$INFO" | awk '{print $2}')
            TYPE=$(echo "$INFO" | awk '{print $3}')
            printf "%-22s %-12s %-16s %-12s\n" "$ID" "$STATE" "$IP" "$TYPE"
        done
        echo "================================================================"
        ;;

    *)
        echo "❌ Unknown action: $ACTION"
        echo "Usage: $0 {start|stop|status} INSTANCE_ID [INSTANCE_ID ...]"
        exit 1
        ;;
esac
