# 🚀 Lambda + API Gateway Integration Guide

## 📋 Overview

This project demonstrates **serverless REST API** creation using AWS Lambda and API Gateway. It's the foundation for building scalable, cost-effective APIs without managing servers.

## 🏗️ Architecture

```
┌──────────────┐
│   Client     │
│ (Browser/    │
│  Postman)    │
└──────┬───────┘
       │ GET /hello?name=John
       ▼
┌─────────────────────────────────────────┐
│      API Gateway (REST API)             │
│  • Regional Endpoint                    │
│  • /hello resource                      │
│  • GET method                           │
│  • AWS_PROXY integration                │
└──────┬──────────────────────────────────┘
       │ Invoke (POST)
       ▼
┌─────────────────────────────────────────┐
│      Lambda Function                    │
│  • Python 3.10                          │
│  • Processes request                    │
│  • Returns JSON response                │
└──────┬──────────────────────────────────┘
       │ Logs
       ▼
┌─────────────────────────────────────────┐
│      CloudWatch Logs                    │
│  • Request/Response logs                │
│  • Error tracking                       │
│  • 7-day retention                      │
└─────────────────────────────────────────┘
```

## 🎯 What This Project Teaches

### 1. **Serverless Computing**
- No server management
- Pay only for execution time
- Auto-scaling built-in

### 2. **API Gateway Concepts**
- REST API creation
- Resources and methods
- Lambda proxy integration
- Deployment stages

### 3. **Lambda Functions**
- Event-driven execution
- Handler function pattern
- Environment variables
- CloudWatch logging

### 4. **IAM Permissions**
- Lambda execution role
- API Gateway invoke permissions
- CloudWatch logging permissions

## 📁 Project Structure

```
lambda_apigw_1/
├── apigw.tf              # API Gateway configuration
├── lambda.tf             # Lambda function definition
├── iam.tf                # IAM roles and policies
├── variable.tf           # Input variables
├── provider.tf           # AWS provider config
├── terraform.tfvars      # Configuration values
├── lambda/
│   ├── hello.py          # Lambda function code
│   └── hello.zip         # Packaged function (auto-generated)
└── README.md             # This file
```

## 🔄 Request Flow

### Step-by-Step Execution

1. **Client sends GET request**
   ```bash
   GET https://api-id.execute-api.us-east-1.amazonaws.com/dev/hello?name=John
   ```

2. **API Gateway receives request**
   - Validates HTTP method (GET)
   - Checks resource path (/hello)
   - Extracts query parameters

3. **API Gateway invokes Lambda**
   - Uses AWS_PROXY integration
   - Sends entire request as event object
   - Waits for Lambda response

4. **Lambda processes request**
   ```python
   # Extract query parameter
   name = event.get('queryStringParameters').get('name', 'Chirag Rathi')
   
   # Build response
   return {
       "statusCode": 200,
       "body": json.dumps({"message": f"Hello, {name}!"})
   }
   ```

5. **API Gateway returns response**
   - Adds CORS headers
   - Returns to client
   - Logs to CloudWatch

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
region         = "us-east-1"
project_name   = "my-api"
api_stage_name = "dev"
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

## 🧪 Testing

### Test with curl
```bash
# Get API endpoint
API_URL=$(terraform output -raw api_endpoint_url)

# Test without parameter (uses default name)
curl $API_URL

# Test with name parameter
curl "$API_URL?name=Alice"

# Test with multiple parameters
curl "$API_URL?name=Bob&greeting=Hi"
```

### Test with Postman
```
Method: GET
URL: https://your-api-id.execute-api.us-east-1.amazonaws.com/dev/hello
Query Params:
  name: John
```

### Expected Response
```json
{
  "message": "Hello, John! Your request was successful.",
  "status": "success"
}
```

### Check Logs
```bash
# Lambda logs
aws logs tail /aws/lambda/my-api-lambda-apigw --follow

# API Gateway logs
aws logs tail "API-Gateway-Execution-Logs_<api-id>/dev" --follow
```

## 🔍 Key Components Explained

### API Gateway REST API

**Why REST API (not HTTP API)?**
- More features (method responses, integration responses)
- Better for learning API Gateway concepts
- Supports more integration types

**Regional vs Edge-Optimized:**
```hcl
endpoint_configuration {
  types = ["REGIONAL"]  # Cheaper, good for single region
}
```
- **REGIONAL**: Lower cost, single region
- **EDGE**: Uses CloudFront, global distribution, higher cost

### Lambda Proxy Integration

```hcl
type = "AWS_PROXY"
```

**What it does:**
- Passes entire request to Lambda as-is
- Lambda controls response format
- Simplifies API Gateway configuration

**Event Structure:**
```json
{
  "resource": "/hello",
  "path": "/hello",
  "httpMethod": "GET",
  "queryStringParameters": {
    "name": "John"
  },
  "headers": {
    "User-Agent": "curl/7.68.0"
  },
  "body": null
}
```

### Lambda Response Format

**Required format for AWS_PROXY:**
```python
{
    "statusCode": 200,                    # HTTP status code
    "headers": {                          # Response headers
        "Content-Type": "application/json"
    },
    "body": json.dumps(data)              # Must be string!
}
```

**Common mistake:**
```python
# ❌ Wrong - body must be string
return {"statusCode": 200, "body": {"key": "value"}}

# ✅ Correct - body is JSON string
return {"statusCode": 200, "body": json.dumps({"key": "value"})}
```

### API Gateway Deployment

```hcl
triggers = {
  redeployment = sha1(jsonencode([
    aws_api_gateway_resource.hello_resource.id,
    aws_api_gateway_method.hello_get.id,
    aws_api_gateway_integration.lambda_integration.id,
  ]))
}
```

**Why triggers?**
- API Gateway doesn't auto-deploy on changes
- Triggers force redeployment when config changes
- Ensures changes are live

### Lambda Permission

```hcl
resource "aws_lambda_permission" "apigw_invoke_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_apigw.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.lambda_api.execution_arn}/*/*"
}
```

**Without this:**
- API Gateway gets "Access Denied" when invoking Lambda
- Lambda execution fails
- 500 Internal Server Error returned

## 💡 Real-World Use Cases

### 1. **User Authentication API**
```python
def lambda_handler(event, context):
    body = json.loads(event['body'])
    username = body.get('username')
    password = body.get('password')
    
    # Validate credentials
    if authenticate(username, password):
        return {
            "statusCode": 200,
            "body": json.dumps({"token": generate_token(username)})
        }
    return {
        "statusCode": 401,
        "body": json.dumps({"error": "Invalid credentials"})
    }
```

### 2. **Data Retrieval API**
```python
def lambda_handler(event, context):
    user_id = event['pathParameters']['userId']
    
    # Get from DynamoDB
    user = dynamodb.get_item(Key={'userId': user_id})
    
    return {
        "statusCode": 200,
        "body": json.dumps(user)
    }
```

### 3. **Webhook Receiver**
```python
def lambda_handler(event, context):
    # Receive webhook from external service
    payload = json.loads(event['body'])
    
    # Process webhook
    process_webhook(payload)
    
    # Send to SQS for async processing
    sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=json.dumps(payload))
    
    return {"statusCode": 200, "body": "Webhook received"}
```

## 🎓 Interview Questions

### Q1: What's the difference between REST API and HTTP API in API Gateway?

**Answer:**
- **REST API**: More features (method responses, API keys, usage plans), higher cost
- **HTTP API**: Simpler, cheaper (70% less), faster, good for Lambda proxy
- **Use REST API**: Complex requirements, API keys, throttling
- **Use HTTP API**: Simple Lambda proxy, cost-sensitive

### Q2: Why does Lambda integration use POST even for GET requests?

**Answer:**
- API Gateway always invokes Lambda using POST
- The actual HTTP method (GET/POST/PUT) is passed in the event object
- Lambda reads `event['httpMethod']` to determine original method
- This is AWS's internal protocol, not visible to end users

### Q3: What happens if Lambda times out?

**Answer:**
1. Lambda execution stops after timeout (default 3s, max 15min)
2. API Gateway receives 504 Gateway Timeout
3. Client gets 504 error
4. CloudWatch logs show timeout error
5. **Solution**: Increase timeout or optimize Lambda code

### Q4: How does API Gateway handle CORS?

**Answer:**
```hcl
# Method response
response_parameters = {
  "method.response.header.Access-Control-Allow-Origin" = true
}

# Integration response
response_parameters = {
  "method.response.header.Access-Control-Allow-Origin" = "'*'"
}
```
- Must configure in both method response and integration response
- `'*'` allows all origins (use specific domain in production)
- Also need OPTIONS method for preflight requests

### Q5: What's the cost of this architecture?

**Answer:**
- **API Gateway**: $3.50 per million requests
- **Lambda**: $0.20 per million requests (128MB, 1s execution)
- **CloudWatch Logs**: $0.50 per GB
- **Example**: 1M requests/month = ~$4.20/month
- **Free Tier**: 1M Lambda requests, 1M API Gateway requests free

## 🐛 Troubleshooting

### Issue 1: 403 Forbidden Error

**Cause:** Lambda permission missing

**Solution:**
```bash
# Check Lambda permission
aws lambda get-policy --function-name my-api-lambda-apigw

# Verify API Gateway has permission to invoke
```

### Issue 2: 502 Bad Gateway

**Cause:** Lambda response format incorrect

**Solution:**
```python
# ✅ Correct format
return {
    "statusCode": 200,
    "body": json.dumps({"message": "Hello"})  # Body must be string!
}
```

### Issue 3: Changes not reflected

**Cause:** API Gateway not redeployed

**Solution:**
```bash
# Force redeployment
terraform taint aws_api_gateway_deployment.lambda_api_deployment
terraform apply
```

### Issue 4: Lambda logs not appearing

**Cause:** IAM permissions missing

**Solution:**
```hcl
# Ensure Lambda role has CloudWatch permissions
Action = [
  "logs:CreateLogGroup",
  "logs:CreateLogStream",
  "logs:PutLogEvents"
]
```

## 🚀 Enhancements

### 1. Add POST Method
```hcl
resource "aws_api_gateway_method" "hello_post" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  resource_id   = aws_api_gateway_resource.hello_resource.id
  http_method   = "POST"
  authorization = "NONE"
}
```

### 2. Add API Key Authentication
```hcl
resource "aws_api_gateway_api_key" "my_key" {
  name = "my-api-key"
}

resource "aws_api_gateway_method" "hello_get" {
  # ... existing config
  authorization = "NONE"
  api_key_required = true
}
```

### 3. Add Request Validation
```hcl
resource "aws_api_gateway_request_validator" "validator" {
  name                        = "request-validator"
  rest_api_id                 = aws_api_gateway_rest_api.lambda_api.id
  validate_request_parameters = true
}
```

### 4. Add Custom Domain
```hcl
resource "aws_api_gateway_domain_name" "custom" {
  domain_name              = "api.example.com"
  certificate_arn          = aws_acm_certificate.cert.arn
}
```

### 5. Add CloudWatch Alarms
```hcl
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
}
```

## 💰 Cost Optimization

### 1. **Use HTTP API instead of REST API**
- 70% cheaper
- Same functionality for simple use cases

### 2. **Optimize Lambda memory**
```hcl
resource "aws_lambda_function" "lambda_apigw" {
  memory_size = 128  # Start small, increase if needed
}
```

### 3. **Reduce log retention**
```hcl
retention_in_days = 1  # Minimum for development
```

### 4. **Use Lambda reserved concurrency**
```hcl
reserved_concurrent_executions = 10  # Prevent runaway costs
```

## 📚 Learning Resources

- [API Gateway Developer Guide](https://docs.aws.amazon.com/apigateway/latest/developerguide/)
- [Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/)
- [API Gateway + Lambda Tutorial](https://docs.aws.amazon.com/lambda/latest/dg/services-apigateway-tutorial.html)
- [Serverless Patterns](https://serverlessland.com/patterns)

## 🧹 Cleanup

```bash
# Destroy all resources
terraform destroy -auto-approve

# Verify deletion
aws lambda list-functions
aws apigateway get-rest-apis
```

## 📝 Next Steps

1. **Add more HTTP methods** (POST, PUT, DELETE)
2. **Integrate with DynamoDB** for data persistence
3. **Add authentication** (API keys, Cognito)
4. **Implement CRUD operations**
5. **Add request/response validation**
6. **Set up custom domain**
7. **Add monitoring and alarms**

---

**Built for learning serverless API development on AWS** 🚀
