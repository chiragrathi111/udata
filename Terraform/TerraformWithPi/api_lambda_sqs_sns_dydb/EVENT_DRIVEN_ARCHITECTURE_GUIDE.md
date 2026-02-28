# 🚀 Event-Driven Serverless Order Processing System

## 📋 Overview

This project implements a **fully serverless, event-driven order processing system** using AWS services orchestrated with Terraform. It demonstrates asynchronous message processing, decoupling, and scalability patterns.

## 🏗️ Architecture

```
┌─────────────┐
│   Client    │
│  (Postman)  │
└──────┬──────┘
       │ POST /order
       ▼
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway (REST)                        │
│                    Endpoint: /order                          │
└──────────────────────────┬──────────────────────────────────┘
                           │ Invoke
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Lambda Producer (Python 3.10)                   │
│  • Receives order from API Gateway                           │
│  • Sends message to SQS queue                                │
│  • Returns 200 OK immediately (async processing)             │
└──────────────────────────┬──────────────────────────────────┘
                           │ Send Message
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    SQS Queue (order_queue)                   │
│  • Decouples producer from consumer                          │
│  • Buffers messages during traffic spikes                    │
│  • Automatic retry on Lambda failure                         │
└──────────────────────────┬──────────────────────────────────┘
                           │ Event Source Mapping (Batch=1)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Lambda Consumer (Python 3.10)                   │
│  • Triggered automatically by SQS                            │
│  • Processes order (adds OrderId, Timestamp)                 │
│  • Stores in DynamoDB                                        │
│  • Sends SNS notification                                    │
└──────────┬──────────────────────────┬───────────────────────┘
           │                          │
           ▼                          ▼
┌──────────────────────┐   ┌──────────────────────┐
│  DynamoDB (Orders)   │   │   SNS Topic          │
│  • Hash Key: OrderId │   │   • Email Subscriber │
│  • Pay-per-request   │   │   • Notification     │
└──────────────────────┘   └──────────────────────┘
```

## 🎯 Key Concepts

### 1. **Event-Driven Architecture**
- **Asynchronous Processing**: API returns immediately; processing happens in background
- **Loose Coupling**: Services communicate via events, not direct calls
- **Scalability**: Each component scales independently

### 2. **Producer-Consumer Pattern**
- **Producer (Lambda 1)**: Receives requests, publishes to queue
- **Queue (SQS)**: Buffers messages, ensures delivery
- **Consumer (Lambda 2)**: Processes messages, stores data

### 3. **Decoupling Benefits**
- Producer doesn't wait for consumer
- Consumer can fail/retry without affecting producer
- Queue absorbs traffic spikes

## 📁 Project Structure

```
api_lambda_sqs_sns_dydb/
├── api.tf                    # API Gateway configuration
├── lambda.tf                 # Lambda functions & event mapping
├── sqs.tf                    # SQS queue
├── sns.tf                    # SNS topic & email subscription
├── dynamodb.tf               # DynamoDB table
├── iam.tf                    # IAM roles & policies
├── variable.tf               # Input variables
├── provider.tf               # AWS provider
├── lambda_producer.py        # Producer Lambda code
├── lambda_consumer.py        # Consumer Lambda code
└── terraform.tfvars          # Configuration values
```

## 🔄 Message Flow

### Step-by-Step Execution

1. **Client sends POST request**
   ```bash
   POST https://api-id.execute-api.us-east-1.amazonaws.com/dev/order
   Body: {"productId": "P123", "quantity": 5, "customer": "John"}
   ```

2. **API Gateway invokes Producer Lambda**
   - Validates request
   - Passes event to Lambda

3. **Producer Lambda sends to SQS**
   ```python
   sqs.send_message(
       QueueUrl=QUEUE_URL,
       MessageBody=json.dumps(event)
   )
   ```
   - Returns 200 immediately
   - Client doesn't wait for processing

4. **SQS stores message**
   - Message persisted in queue
   - Waits for consumer

5. **Event Source Mapping triggers Consumer Lambda**
   - Polls SQS automatically
   - Invokes Lambda with batch of messages

6. **Consumer Lambda processes order**
   ```python
   # Add OrderId if missing
   order['OrderId'] = str(uuid.uuid4())
   
   # Add timestamp
   order['Timestamp'] = datetime.utcnow().isoformat()
   
   # Store in DynamoDB
   table.put_item(Item=order)
   
   # Send SNS notification
   sns.publish(TopicArn=TOPIC_ARN, Message=f"Order processed: {order}")
   ```

7. **DynamoDB stores order**
   - Persistent storage
   - Fast key-value access

8. **SNS sends email notification**
   - Email to subscribed address
   - Confirms order processing

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
region       = "us-east-1"
project_name = "order-processing"
email        = "your-email@example.com"
stage_name   = "dev"
```

### Deploy
```bash
# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply -auto-approve

# Get API endpoint
terraform output api_endpoint_url
```

### Confirm SNS Subscription
After deployment, check your email and **confirm the SNS subscription**.

## 🧪 Testing

### Test with curl
```bash
# Get API endpoint
API_URL=$(terraform output -raw api_endpoint_url)

# Send order
curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "productId": "PROD-001",
    "quantity": 3,
    "customer": "Alice Smith",
    "price": 29.99
  }'
```

### Test with Postman
```
Method: POST
URL: https://your-api-id.execute-api.us-east-1.amazonaws.com/dev/order
Headers:
  Content-Type: application/json
Body (raw JSON):
{
  "productId": "PROD-002",
  "quantity": 5,
  "customer": "Bob Johnson",
  "price": 49.99
}
```

### Verify Results

1. **Check DynamoDB**
   ```bash
   aws dynamodb scan --table-name Orders
   ```

2. **Check Email**
   - You should receive notification email

3. **Check CloudWatch Logs**
   ```bash
   # Producer logs
   aws logs tail /aws/lambda/order-processing_lambda_producer --follow
   
   # Consumer logs
   aws logs tail /aws/lambda/order-processing_lambda_consumer --follow
   ```

## 🔍 Key Components Explained

### API Gateway Configuration

**Why REST API (not HTTP API)?**
- More features (method responses, integration responses)
- Better for learning API Gateway concepts
- CORS support

**Deployment Triggers**
```hcl
triggers = {
  redeployment = sha1(jsonencode([
    aws_api_gateway_resource.order_api.id,
    aws_api_gateway_method.post.id,
    aws_api_gateway_integration.order_interation.id
  ]))
}
```
- Redeploys API when configuration changes
- Ensures changes are live

### Lambda Event Source Mapping

```hcl
resource "aws_lambda_event_source_mapping" "sqs_lambda_trigger" {
  event_source_arn = aws_sqs_queue.order_queue.arn
  function_name    = aws_lambda_function.lambda_consumer.arn
  batch_size       = 1
  enabled          = true
}
```

**What it does:**
- AWS polls SQS queue automatically
- Invokes Lambda when messages available
- Handles retries on failure
- Deletes messages after successful processing

**Batch Size = 1:**
- Process one message at a time
- Simpler error handling
- Can increase for higher throughput

### SQS Queue Benefits

1. **Buffering**: Handles traffic spikes
2. **Retry Logic**: Automatic redelivery on failure
3. **Dead Letter Queue**: Can add for failed messages
4. **Visibility Timeout**: Prevents duplicate processing

### DynamoDB Pay-Per-Request

```hcl
billing_mode = "PAY_PER_REQUEST"
```

**Benefits:**
- No capacity planning needed
- Pay only for actual reads/writes
- Auto-scales with traffic
- Perfect for unpredictable workloads

### IAM Permissions

**Lambda Role needs:**
- CloudWatch Logs (logging)
- SQS (send/receive messages)
- DynamoDB (put items)
- SNS (publish notifications)

**Note:** Current policy uses `*` for resources (simplified). In production, use specific ARNs.

## 💡 Real-World Use Cases

### 1. **E-Commerce Order Processing**
```
Customer places order → API Gateway → Lambda Producer → SQS
→ Lambda Consumer → Store in DB → Send confirmation email
```

### 2. **Image Processing Pipeline**
```
Upload image → S3 → Lambda → SQS → Lambda → Process image
→ Store metadata in DynamoDB → SNS notification
```

### 3. **IoT Data Ingestion**
```
IoT device sends data → API Gateway → Lambda → SQS
→ Lambda → Store in DynamoDB → SNS alert if threshold exceeded
```

### 4. **Webhook Processing**
```
External service webhook → API Gateway → Lambda → SQS
→ Lambda → Process data → Store → Notify team
```

## 🎓 Interview Questions

### Q1: Why use SQS between two Lambdas?
**Answer:**
- **Decoupling**: Producer doesn't wait for consumer
- **Buffering**: Handles traffic spikes (1000 req/sec → queue → process at Lambda's pace)
- **Retry Logic**: Consumer fails → message returns to queue → automatic retry
- **Scalability**: Consumer can scale independently based on queue depth

### Q2: What happens if Consumer Lambda fails?
**Answer:**
1. Message returns to SQS (visibility timeout expires)
2. SQS retries delivery (default: 3 times)
3. After max retries, can send to Dead Letter Queue (DLQ)
4. Producer is unaffected (already returned 200 to client)

### Q3: Why not call DynamoDB directly from Producer Lambda?
**Answer:**
- **Async Processing**: Client gets immediate response
- **Fault Tolerance**: If DynamoDB is slow/down, messages queue up
- **Rate Limiting**: SQS buffers; consumer processes at sustainable rate
- **Retry Logic**: Built-in retry without custom code

### Q4: How does Event Source Mapping work?
**Answer:**
- AWS service that polls SQS on your behalf
- Invokes Lambda with batch of messages
- Manages visibility timeout
- Deletes messages after successful processing
- Handles partial batch failures (can configure)

### Q5: What's the difference between SNS and SQS?
**Answer:**
- **SNS (Pub/Sub)**: One message → multiple subscribers (fan-out)
- **SQS (Queue)**: One message → one consumer (point-to-point)
- **Use SNS**: Notifications, multiple destinations
- **Use SQS**: Work queues, decoupling, buffering

## 🐛 Troubleshooting

### Issue 1: Messages not reaching Consumer Lambda

**Check:**
```bash
# Verify Event Source Mapping
aws lambda list-event-source-mappings \
  --function-name order-processing_lambda_consumer

# Check SQS queue
aws sqs get-queue-attributes \
  --queue-url $(terraform output -raw aws_sqs_arn | sed 's/arn:aws:sqs:/https:\/\/sqs./;s/:/ /;s/:/.amazonaws.com\//') \
  --attribute-names ApproximateNumberOfMessages
```

**Solution:**
- Ensure Event Source Mapping is enabled
- Check Lambda permissions (sqs:ReceiveMessage, sqs:DeleteMessage)

### Issue 2: DynamoDB PutItem fails

**Error:** `ValidationException: One or more parameter values were invalid`

**Cause:** Missing OrderId (hash key)

**Solution:** Consumer Lambda adds OrderId if missing:
```python
if 'OrderId' not in order:
    order['OrderId'] = str(uuid.uuid4())
```

### Issue 3: SNS email not received

**Check:**
1. Confirm subscription (check email for confirmation link)
2. Check spam folder
3. Verify SNS topic ARN in Lambda environment variable

```bash
# Check subscription status
aws sns list-subscriptions-by-topic \
  --topic-arn $(terraform output -raw sns_topic_arn)
```

### Issue 4: API Gateway returns 500

**Check CloudWatch Logs:**
```bash
aws logs tail /aws/lambda/order-processing_lambda_producer --follow
```

**Common causes:**
- Lambda timeout (increase timeout)
- IAM permissions missing
- SQS queue URL incorrect

## 💰 Cost Breakdown (Monthly)

| Service | Usage | Cost |
|---------|-------|------|
| API Gateway | 1M requests | $3.50 |
| Lambda (Producer) | 1M invocations, 128MB, 1s | $0.20 |
| Lambda (Consumer) | 1M invocations, 128MB, 1s | $0.20 |
| SQS | 1M requests | $0.40 |
| DynamoDB | 1M writes, 1M reads | $1.25 |
| SNS | 1M notifications | $0.50 |
| CloudWatch Logs | 5GB | $2.50 |
| **Total** | | **~$8.55/month** |

**Free Tier:**
- Lambda: 1M requests/month free
- DynamoDB: 25GB storage, 25 WCU, 25 RCU free
- SNS: 1M publishes free
- SQS: 1M requests free

## 🚀 Enhancements

### 1. Add Dead Letter Queue (DLQ)
```hcl
resource "aws_sqs_queue" "order_dlq" {
  name = "order-dlq"
}

resource "aws_sqs_queue" "order_queue" {
  name = "order_queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_dlq.arn
    maxReceiveCount     = 3
  })
}
```

### 2. Add X-Ray Tracing
```hcl
resource "aws_lambda_function" "lambda_producer" {
  # ... existing config
  tracing_config {
    mode = "Active"
  }
}
```

### 3. Add API Key Authentication
```hcl
resource "aws_api_gateway_api_key" "order_api_key" {
  name = "order-api-key"
}

resource "aws_api_gateway_usage_plan" "order_usage_plan" {
  name = "order-usage-plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.rest_api.id
    stage  = aws_api_gateway_stage.order_stage.stage_name
  }
}
```

### 4. Add CloudWatch Alarms
```hcl
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "lambda-consumer-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_actions       = [aws_sns_topic.order_topic.arn]
}
```

## 📚 Learning Resources

- [AWS Lambda Event Source Mappings](https://docs.aws.amazon.com/lambda/latest/dg/invocation-eventsourcemapping.html)
- [SQS Best Practices](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-best-practices.html)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [Event-Driven Architecture Patterns](https://aws.amazon.com/event-driven-architecture/)

## 🧹 Cleanup

```bash
# Destroy all resources
terraform destroy -auto-approve

# Verify deletion
aws dynamodb list-tables
aws sqs list-queues
aws sns list-topics
```

---

**Built for learning serverless event-driven architectures on AWS** 🚀
