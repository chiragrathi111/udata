# 📁 S3-Triggered Lambda File Processing System

## 📋 Overview

This project demonstrates **event-driven file processing** using S3 and Lambda. When files are uploaded to S3, Lambda automatically processes them - perfect for image processing, document conversion, data transformation, and more.

## 🏗️ Architecture

```
┌──────────────────┐
│   User/Client    │
│  Uploads File    │
└────────┬─────────┘
         │ PUT object
         ▼
┌─────────────────────────────────────────┐
│      S3 Upload Bucket                   │
│  • Receives file uploads                │
│  • Triggers Lambda on upload            │
│  • Versioning enabled                   │
│  • Encrypted (AES256)                   │
└────────┬────────────────────────────────┘
         │ S3 Event Notification
         ▼
┌─────────────────────────────────────────┐
│      Lambda Function                    │
│  • Triggered automatically              │
│  • Copies file to destination           │
│  • Creates processing record            │
│  • Generates logs                       │
└────────┬────────────────────────────────┘
         │ Copy & Create Records
         ▼
┌─────────────────────────────────────────┐
│   S3 Destination Bucket                 │
│  • /                  (original file)   │
│  • /processed/        (timestamped)     │
│  • /records/          (metadata JSON)   │
│  • /logs/             (processing logs) │
│  • /errors/           (error records)   │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│      CloudWatch Logs                    │
│  • Lambda execution logs                │
│  • Error tracking                       │
│  • 7-day retention                      │
└─────────────────────────────────────────┘
```

## 🎯 What This Project Teaches

### 1. **S3 Event Notifications**
- Trigger Lambda on file upload
- Event filtering (prefix, suffix)
- Event structure and parsing

### 2. **Lambda S3 Integration**
- Read from S3
- Copy objects between buckets
- Create new objects
- Handle S3 events

### 3. **File Processing Patterns**
- Event-driven processing
- Automatic scaling
- Error handling
- Audit trail creation

### 4. **Security Best Practices**
- Bucket encryption
- Public access blocking
- IAM least privilege
- Versioning for recovery

## 📁 Project Structure

```
lambda_image/
├── lambda.tf             # Lambda function & S3 notification
├── s3.tf                 # S3 buckets configuration
├── iam.tf                # IAM roles and policies
├── varibale.tf           # Input variables
├── provider.tf           # AWS provider config
├── terraform.tfvars      # Configuration values
├── lambda_image.py       # Lambda function code
└── lambda_image.zip      # Packaged function (auto-generated)
```

## 🔄 Processing Flow

### Step-by-Step Execution

1. **User uploads file to S3**
   ```bash
   aws s3 cp myimage.jpg s3://upload-bucket/myimage.jpg
   ```

2. **S3 triggers Lambda**
   - S3 detects ObjectCreated event
   - Sends event to Lambda
   - Event contains bucket name, object key, size, etc.

3. **Lambda processes file**
   ```python
   # Extract event info
   source_bucket = record['s3']['bucket']['name']
   object_key = record['s3']['object']['key']
   
   # Copy to destination (original filename)
   s3_client.copy_object(
       CopySource={'Bucket': source_bucket, 'Key': object_key},
       Bucket=destination_bucket,
       Key=object_key
   )
   
   # Also save timestamped copy
   processed_key = f"processed/{timestamp}_{object_key}"
   s3_client.copy_object(...)
   
   # Create processing record
   record = {
       "source": object_key,
       "destination": destination_key,
       "status": "SUCCESS"
   }
   s3_client.put_object(
       Bucket=destination_bucket,
       Key=f"records/{timestamp}_record.json",
       Body=json.dumps(record)
   )
   ```

4. **Files created in destination bucket**
   - `/myimage.jpg` - Original file (same name)
   - `/processed/20240115_143022_myimage.jpg` - Timestamped copy
   - `/records/20240115_143022_myimage.jpg_record.json` - Processing metadata
   - `/logs/20240115_143022_processing_log.json` - Processing log

5. **CloudWatch logs updated**
   - Execution details
   - Processing summary
   - Any errors

## 🛠️ Deployment

### Prerequisites
```bash
# AWS CLI configured
aws configure

# Terraform installed
terraform version  # v1.14+
```

### Configuration

**terraform.tfvars**
```hcl
region      = "us-east-1"
project_name = "file-processor"
environment = "dev"
memorySize  = 256
timeout     = 60
```

### Deploy
```bash
# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply -auto-approve

# Get bucket names
terraform output upload_bucket_name
terraform output destination_bucket_name
```

## 🧪 Testing

### Test 1: Upload Image File
```bash
# Get upload bucket name
UPLOAD_BUCKET=$(terraform output -raw upload_bucket_name)

# Upload test image
aws s3 cp test-image.jpg s3://$UPLOAD_BUCKET/test-image.jpg

# Check destination bucket
DEST_BUCKET=$(terraform output -raw destination_bucket_name)
aws s3 ls s3://$DEST_BUCKET/ --recursive
```

### Expected Output in Destination Bucket
```
test-image.jpg                                    # Original file
processed/20240115_143022_test-image.jpg          # Timestamped copy
records/20240115_143022_test-image.jpg_record.json # Processing record
logs/20240115_143022_processing_log.json          # Processing log
```

### Test 2: Upload Multiple Files
```bash
# Upload multiple files
for i in {1..5}; do
  echo "Test file $i" > test$i.txt
  aws s3 cp test$i.txt s3://$UPLOAD_BUCKET/
done

# Check processing
aws s3 ls s3://$DEST_BUCKET/processed/
```

### Test 3: Check Processing Record
```bash
# Download and view processing record
aws s3 cp s3://$DEST_BUCKET/records/$(aws s3 ls s3://$DEST_BUCKET/records/ | tail -1 | awk '{print $4}') - | jq .
```

### Expected Record Format
```json
{
  "processing_id": "20240115143022-abc123",
  "source_bucket": "upload-bucket",
  "source_key": "test-image.jpg",
  "destination_bucket": "destination-bucket",
  "destination_key": "test-image.jpg",
  "processed_key": "processed/20240115_143022_test-image.jpg",
  "object_size": 245678,
  "event_name": "ObjectCreated:Put",
  "event_time": "2024-01-15T14:30:22.000Z",
  "processed_time": "2024-01-15T14:30:23.456Z",
  "lambda_function": "file-processor-function-dev",
  "status": "SUCCESS"
}
```

### Check Lambda Logs
```bash
# Get Lambda function name
FUNCTION_NAME=$(terraform output -raw lambda_function_name)

# Tail logs
aws logs tail /aws/lambda/$FUNCTION_NAME --follow

# Search for errors
aws logs tail /aws/lambda/$FUNCTION_NAME --filter-pattern "ERROR"
```

## 🔍 Key Components Explained

### S3 Event Notification

```hcl
resource "aws_s3_bucket_notification" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id
  
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_image_function.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
```

**Event Types:**
- `s3:ObjectCreated:*` - Any object creation (Put, Post, Copy, CompleteMultipartUpload)
- `s3:ObjectCreated:Put` - Only PUT operations
- `s3:ObjectRemoved:*` - Object deletion
- `s3:ObjectRestore:*` - Glacier restore

**Event Filtering:**
```hcl
lambda_function {
  # ... existing config
  filter_prefix = "images/"      # Only trigger for images/ folder
  filter_suffix = ".jpg"         # Only trigger for .jpg files
}
```

### Lambda Permission

```hcl
resource "aws_lambda_permission" "lambda_image" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_image_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}
```

**Why needed:**
- S3 needs explicit permission to invoke Lambda
- Without this, S3 event notification fails
- Scoped to specific bucket (source_arn)

### S3 Bucket Security

```hcl
# Encryption at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

# Versioning for recovery
resource "aws_s3_bucket_versioning" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

### Lambda Event Structure

```python
{
  "Records": [
    {
      "eventVersion": "2.1",
      "eventSource": "aws:s3",
      "eventName": "ObjectCreated:Put",
      "eventTime": "2024-01-15T14:30:22.000Z",
      "s3": {
        "bucket": {
          "name": "upload-bucket",
          "arn": "arn:aws:s3:::upload-bucket"
        },
        "object": {
          "key": "test-image.jpg",
          "size": 245678,
          "eTag": "abc123def456"
        }
      }
    }
  ]
}
```

## 💡 Real-World Use Cases

### 1. **Image Thumbnail Generation**
```python
from PIL import Image
import io

def lambda_handler(event, context):
    # Get original image
    response = s3_client.get_object(Bucket=source_bucket, Key=object_key)
    image_data = response['Body'].read()
    
    # Create thumbnail
    image = Image.open(io.BytesIO(image_data))
    image.thumbnail((200, 200))
    
    # Save thumbnail
    buffer = io.BytesIO()
    image.save(buffer, format='JPEG')
    s3_client.put_object(
        Bucket=destination_bucket,
        Key=f"thumbnails/{object_key}",
        Body=buffer.getvalue()
    )
```

### 2. **Document Format Conversion**
```python
# Convert uploaded Word docs to PDF
def lambda_handler(event, context):
    if object_key.endswith('.docx'):
        # Download Word doc
        # Convert to PDF using library
        # Upload PDF to destination
        pass
```

### 3. **Data File Processing**
```python
# Process CSV uploads
def lambda_handler(event, context):
    if object_key.endswith('.csv'):
        # Read CSV from S3
        # Transform data
        # Write to DynamoDB
        # Save processed CSV
        pass
```

### 4. **Video Transcoding**
```python
# Trigger MediaConvert for video processing
def lambda_handler(event, context):
    if object_key.endswith(('.mp4', '.mov')):
        # Start MediaConvert job
        # Convert to multiple formats
        # Generate thumbnails
        pass
```

### 5. **Malware Scanning**
```python
# Scan uploaded files for viruses
def lambda_handler(event, context):
    # Download file
    # Scan with antivirus
    # Move to quarantine if infected
    # Move to safe bucket if clean
    pass
```

## 🎓 Interview Questions

### Q1: What happens if Lambda fails while processing?

**Answer:**
1. Lambda retries automatically (up to 2 times for S3 events)
2. After retries, event is discarded (not sent to DLQ by default)
3. **Solution**: Add error handling in Lambda, create error records in S3
4. **Better**: Configure Lambda with DLQ (Dead Letter Queue) for failed events

### Q2: Can multiple Lambda functions be triggered by same S3 event?

**Answer:**
- Yes! S3 can send same event to multiple destinations
- Configure multiple lambda_function blocks in aws_s3_bucket_notification
- Use case: One Lambda for thumbnails, another for metadata extraction
- Each Lambda processes independently

### Q3: What's the maximum file size Lambda can process from S3?

**Answer:**
- Lambda has 512MB /tmp storage
- For files > 512MB, use streaming or chunked processing
- Alternative: Use S3 Batch Operations or Step Functions
- Best practice: Process large files in chunks

### Q4: How to prevent duplicate processing if file is uploaded twice?

**Answer:**
```python
# Check if already processed
try:
    s3_client.head_object(
        Bucket=destination_bucket,
        Key=f"processed/{object_key}"
    )
    logger.info("Already processed, skipping")
    return
except ClientError:
    # Not processed yet, continue
    pass
```

### Q5: What's the cost of this architecture?

**Answer:**
- **S3 Storage**: $0.023/GB/month
- **S3 Requests**: $0.005 per 1000 PUT, $0.0004 per 1000 GET
- **Lambda**: $0.20 per 1M requests + $0.0000166667 per GB-second
- **Example**: 10,000 files/month (1MB each) = ~$1.50/month

## 🐛 Troubleshooting

### Issue 1: Lambda not triggered on upload

**Check:**
```bash
# Verify S3 notification configuration
aws s3api get-bucket-notification-configuration \
  --bucket $UPLOAD_BUCKET

# Check Lambda permission
aws lambda get-policy \
  --function-name $FUNCTION_NAME
```

**Solution:**
- Ensure aws_lambda_permission exists
- Verify depends_on in aws_s3_bucket_notification
- Check CloudTrail for S3 API calls

### Issue 2: Permission denied errors

**Error:** `AccessDenied: Access Denied`

**Solution:**
```hcl
# Ensure Lambda role has S3 permissions
Action = [
  "s3:GetObject",
  "s3:PutObject",
  "s3:CopyObject"
]
Resource = [
  "${aws_s3_bucket.upload_bucket.arn}/*",
  "${aws_s3_bucket.destination_bucket.arn}/*"
]
```

### Issue 3: Lambda timeout

**Error:** `Task timed out after 3.00 seconds`

**Solution:**
```hcl
resource "aws_lambda_function" "lambda_image_function" {
  timeout = 60  # Increase timeout
  memory_size = 512  # More memory = faster CPU
}
```

### Issue 4: File not found in destination

**Check:**
```bash
# Check Lambda logs for errors
aws logs tail /aws/lambda/$FUNCTION_NAME --since 5m

# List destination bucket
aws s3 ls s3://$DEST_BUCKET/ --recursive
```

## 🚀 Enhancements

### 1. Add DLQ for Failed Events
```hcl
resource "aws_sqs_queue" "lambda_dlq" {
  name = "lambda-processing-dlq"
}

resource "aws_lambda_function" "lambda_image_function" {
  # ... existing config
  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }
}
```

### 2. Add SNS Notification on Completion
```hcl
resource "aws_sns_topic" "processing_complete" {
  name = "file-processing-complete"
}

# In Lambda code:
sns.publish(
    TopicArn=os.environ['SNS_TOPIC_ARN'],
    Message=f"File {object_key} processed successfully"
)
```

### 3. Add CloudWatch Alarms
```hcl
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "lambda-processing-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
}
```

### 4. Add X-Ray Tracing
```hcl
resource "aws_lambda_function" "lambda_image_function" {
  # ... existing config
  tracing_config {
    mode = "Active"
  }
}
```

## 💰 Cost Optimization

1. **Optimize Lambda memory** - Start with 256MB, increase only if needed
2. **Reduce log retention** - 1 day for dev, 7 days for prod
3. **Use S3 Intelligent-Tiering** - Auto-move old files to cheaper storage
4. **Batch processing** - Process multiple files in single invocation
5. **Filter events** - Only trigger for specific file types

## 📚 Learning Resources

- [S3 Event Notifications](https://docs.aws.amazon.com/AmazonS3/latest/userguide/NotificationHowTo.html)
- [Lambda with S3](https://docs.aws.amazon.com/lambda/latest/dg/with-s3.html)
- [S3 Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)

## 🧹 Cleanup

```bash
# Empty buckets first (required before deletion)
aws s3 rm s3://$UPLOAD_BUCKET --recursive
aws s3 rm s3://$DEST_BUCKET --recursive

# Destroy infrastructure
terraform destroy -auto-approve
```

---

**Built for learning event-driven file processing on AWS** 🚀
