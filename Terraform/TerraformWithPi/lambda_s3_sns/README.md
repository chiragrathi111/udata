# 📧 S3 Upload Email Notification System

## 📋 Overview

Automated email notification system that sends alerts when files are uploaded to S3. Uses Lambda to process S3 events and SNS to send emails.

## 🏗️ Architecture

```
User uploads file → S3 Bucket → Lambda → SNS → Email
```

## 🔄 Flow

1. User uploads file to S3
2. S3 triggers Lambda automatically
3. Lambda extracts file info (name, size, type)
4. Lambda publishes to SNS topic
5. SNS sends email to subscriber

## 🛠️ Deployment

```bash
terraform init
terraform apply -auto-approve
```

**Important**: Check email and confirm SNS subscription after deployment.

## 🧪 Testing

```bash
# Get bucket name
BUCKET=$(terraform output -raw s3_bucket_name)

# Upload test file
echo "Test content" > test.txt
aws s3 cp test.txt s3://$BUCKET/

# Check email for notification
```

## 📧 Email Format

```
Subject: New File Uploaded to S3: test.txt

File Details:
• File Name: test.txt
• Bucket: my-bucket
• File Size: 12 B
• Content Type: text/plain
• Upload Time: 2024-01-15 14:30:22 UTC
```

## 💡 Use Cases

1. **Document Upload Alerts** - Notify when contracts/invoices uploaded
2. **Image Upload Monitoring** - Alert on new profile pictures
3. **Backup Notifications** - Confirm backup files received
4. **Data Pipeline Triggers** - Start processing when data arrives
5. **Security Monitoring** - Alert on unexpected uploads

## 🎓 Key Concepts

**S3 Event Notification**: Triggers Lambda on ObjectCreated
**Lambda Function**: Processes event, formats message
**SNS Topic**: Pub/sub messaging service
**Email Subscription**: Receives notifications

## 🐛 Troubleshooting

**No email received?**
- Confirm SNS subscription via email
- Check spam folder
- Verify Lambda logs: `aws logs tail /aws/lambda/function-name --follow`

**Lambda not triggered?**
- Check S3 notification configuration
- Verify Lambda permission exists
- Check IAM role permissions

## 💰 Cost

- S3: $0.023/GB/month
- Lambda: $0.20 per 1M requests
- SNS: $0.50 per 1M emails
- **Example**: 1000 uploads/month = ~$0.50

## 🚀 Enhancements

1. **Filter by file type**: Only notify for .pdf files
2. **Add Slack notifications**: Use SNS → Lambda → Slack webhook
3. **Store metadata in DynamoDB**: Track all uploads
4. **Add file validation**: Check file size/type before processing
5. **Multiple recipients**: Add more email subscriptions

---

**Built for learning S3 event-driven notifications** 📧
