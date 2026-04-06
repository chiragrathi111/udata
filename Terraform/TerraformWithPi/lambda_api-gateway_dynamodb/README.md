# 🎓 Student Management CRUD API (Serverless)

## 📋 Real-World Scenario

**Company**: EdTech startup managing 50,000+ students  
**Problem**: Old PHP server crashes during exam results day (10x traffic spike)  
**Solution**: Serverless CRUD API that auto-scales from 0 to 10,000 requests/second

---

## 🏗️ Architecture

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────┐     ┌──────────────┐
│   Postman /  │────►│   API Gateway    │────►│    Lambda    │────►│  DynamoDB    │
│   Browser    │◄────│  (REST API)      │◄────│  (Python)    │◄────│  (students)  │
└──────────────┘     └──────────────────┘     └──────────────┘     └──────────────┘
                      POST /students           Create Student       PutItem
                      GET  /students           Get Students         Scan / GetItem
                      PUT  /students           Update Student       UpdateItem
                      DELETE /students         Delete Student       DeleteItem
```

### How It Works (Step by Step)

1. You hit URL in **Postman** → `POST https://xxx.execute-api.ap-south-1.amazonaws.com/prod/students`
2. **API Gateway** receives request, checks method (POST/GET/PUT/DELETE)
3. API Gateway **invokes Lambda** using AWS_PROXY integration
4. **Lambda** reads `event['httpMethod']` to decide what to do
5. Lambda talks to **DynamoDB** (PutItem, GetItem, Scan, UpdateItem, DeleteItem)
6. Lambda returns response → API Gateway → Postman shows result

---

## 📁 Project Structure

```
lambda_api-gateway_dynamodb/
├── provider.tf           # Terraform & AWS provider config
├── variable.tf           # Input variables with defaults
├── terraform.tfvars      # Your configuration values
├── dynamodb.tf           # DynamoDB table (students)
├── iam.tf                # IAM role & policy for Lambda
├── lambda.tf             # Lambda function + permission
├── api-gateway.tf        # API Gateway (GET/POST/PUT/DELETE + deployment + stage)
├── lambda_function.py    # Python CRUD logic
├── output.tf             # API URL output for Postman
└── README.md             # This file
```

---

## 🚀 Deploy

```bash
cd lambda_api-gateway_dynamodb

# Initialize
terraform init

# Check what will be created
terraform plan

# Deploy (creates ~20 resources)
terraform apply -auto-approve

# Get your API URL
terraform output api_students_url
```

**Copy the URL** - this is what you use in Postman!

Example output:
```
api_students_url = "https://abc123xyz.execute-api.ap-south-1.amazonaws.com/prod/students"
```

---

## 🧪 Postman Testing (Step by Step)

### Step 1: CREATE Student (POST)

```
Method: POST
URL:    https://your-api-id.execute-api.ap-south-1.amazonaws.com/prod/students
Headers:
  Content-Type: application/json
Body (raw → JSON):
{
  "name": "Chirag Rathi",
  "email": "chirag@example.com",
  "course": "AWS DevOps",
  "marks": 95
}
```

**Response (201):**
```json
{
  "message": "Student created!",
  "student": {
    "studentId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "name": "Chirag Rathi",
    "email": "chirag@example.com",
    "course": "AWS DevOps",
    "marks": 95,
    "createdAt": "2025-01-15T10:30:00.000000"
  }
}
```

**⚠️ Copy the `studentId` from response - you need it for GET/PUT/DELETE!**

---

### Step 2: GET All Students (GET)

```
Method: GET
URL:    https://your-api-id.execute-api.ap-south-1.amazonaws.com/prod/students
```

**Response (200):**
```json
[
  {
    "studentId": "a1b2c3d4-...",
    "name": "Chirag Rathi",
    "email": "chirag@example.com",
    "course": "AWS DevOps",
    "marks": 95
  }
]
```

---

### Step 3: GET Single Student (GET with query param)

```
Method: GET
URL:    https://your-api-id.execute-api.ap-south-1.amazonaws.com/prod/students?studentId=a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

**Response (200):**
```json
{
  "studentId": "a1b2c3d4-...",
  "name": "Chirag Rathi",
  "email": "chirag@example.com",
  "course": "AWS DevOps",
  "marks": 95
}
```

---

### Step 4: UPDATE Student (PUT)

```
Method: PUT
URL:    https://your-api-id.execute-api.ap-south-1.amazonaws.com/prod/students
Headers:
  Content-Type: application/json
Body (raw → JSON):
{
  "studentId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "name": "Chirag Rathi Updated",
  "email": "chirag.new@example.com",
  "course": "AWS Solutions Architect",
  "marks": 99
}
```

**Response (200):**
```json
{
  "message": "Student updated!"
}
```

---

### Step 5: DELETE Student (DELETE)

```
Method: DELETE
URL:    https://your-api-id.execute-api.ap-south-1.amazonaws.com/prod/students?studentId=a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

**Response (200):**
```json
{
  "message": "Student deleted!"
}
```

---

## 🔍 API Gateway Explained (For Your Understanding)

### What is API Gateway?

Think of it as a **receptionist** at a company:
- Customer (Postman) comes to the door
- Receptionist (API Gateway) checks what they want
- Sends them to the right department (Lambda function)
- Returns the answer back to customer

### Key Concepts

| Concept | What It Is | Example |
|---------|-----------|---------|
| **REST API** | The main API object | `StudentManagement-api` |
| **Resource** | URL path | `/students` |
| **Method** | HTTP method on a resource | `GET /students`, `POST /students` |
| **Integration** | What to call when method is hit | Lambda function |
| **Deployment** | Snapshot of API config | Like "saving" your API |
| **Stage** | Version of deployment | `prod`, `dev`, `staging` |

### Why AWS_PROXY Integration?

```hcl
type = "AWS_PROXY"
```

- API Gateway sends **entire request** to Lambda as-is
- Lambda controls the **full response** (status code, headers, body)
- **Simplest** integration type - no mapping templates needed
- Lambda receives `event['httpMethod']`, `event['body']`, `event['queryStringParameters']`

### Why integration_http_method = "POST"?

```hcl
integration_http_method = "POST"  # Even for GET/PUT/DELETE methods!
```

This confuses everyone! Here's why:
- This is how API Gateway **internally calls Lambda** (always POST)
- The **actual HTTP method** (GET/PUT/DELETE) is passed inside `event['httpMethod']`
- Your Lambda reads `event['httpMethod']` to decide what to do

### How Deployment + Stage Works

```
You create methods → Nothing happens (API not live)
You create deployment → Snapshot taken
You create stage → Stage gets a URL

URL format: https://{api-id}.execute-api.{region}.amazonaws.com/{stage}/{resource}
Example:    https://abc123.execute-api.ap-south-1.amazonaws.com/prod/students
```

**Without deployment + stage = NO URL = can't use in Postman!**

---

## 🐛 Troubleshooting

### Error: "Missing Authentication Token" (403)
**Cause**: Wrong URL or missing `/students` path  
**Fix**: Make sure URL ends with `/students`
```
❌ https://abc123.execute-api.ap-south-1.amazonaws.com/prod
✅ https://abc123.execute-api.ap-south-1.amazonaws.com/prod/students
```

### Error: "Internal Server Error" (500)
**Cause**: Lambda crashed  
**Fix**: Check CloudWatch logs
```bash
aws logs tail /aws/lambda/student-management --follow --region ap-south-1
```

### Error: "Forbidden" (403)
**Cause**: Lambda permission missing  
**Fix**: Check `aws_lambda_permission` resource exists in lambda.tf

### Error: "Method Not Allowed" (405)
**Cause**: That HTTP method not configured in API Gateway  
**Fix**: All 4 methods (GET/POST/PUT/DELETE) are now configured ✅

### Error: Changes not reflecting
**Cause**: API Gateway not redeployed  
**Fix**: 
```bash
terraform taint aws_api_gateway_deployment.student_api
terraform apply
```

---

## 🎓 Interview Questions

### Q1: Why DynamoDB instead of RDS (MySQL)?

**Answer**: 
- **DynamoDB**: Serverless, auto-scales, pay-per-request, single-digit ms latency
- **RDS**: Need to manage instance size, connections, backups
- For this use case (key-value lookups by studentId), DynamoDB is perfect
- If we needed complex JOINs or transactions, I'd use RDS

### Q2: What happens when 10,000 students hit the API at same time?

**Answer**:
- API Gateway handles up to 10,000 requests/second by default
- Lambda auto-scales to 1000 concurrent executions
- DynamoDB PAY_PER_REQUEST auto-scales reads/writes
- **Zero manual intervention needed** - that's the power of serverless

### Q3: How does Lambda know which HTTP method was called?

**Answer**:
```python
method = event.get('httpMethod')  # Returns 'GET', 'POST', 'PUT', 'DELETE'

if method == 'POST':
    # Create student
elif method == 'GET':
    # Read student(s)
```
API Gateway passes the full request as `event` object to Lambda. Lambda reads `httpMethod` to decide what to do.

### Q4: What is AWS_PROXY integration?

**Answer**:
- API Gateway sends **entire HTTP request** to Lambda as-is
- Lambda has **full control** over the response format
- Lambda must return `statusCode`, `headers`, and `body`
- Simplest integration - no mapping templates needed
- Alternative: AWS integration (you map request/response manually)

### Q5: Why do you need `aws_api_gateway_deployment` and `aws_api_gateway_stage`?

**Answer**:
- **Deployment**: Takes a snapshot of your API configuration
- **Stage**: Makes that snapshot accessible via a URL
- Without these, your API exists but has **no URL to call**
- Stage name becomes part of URL: `/prod/students`, `/dev/students`
- You can have multiple stages pointing to different deployments

---

## 💰 Cost

| Service | Free Tier | After Free Tier |
|---------|-----------|-----------------|
| API Gateway | 1M requests/month | $3.50 per million |
| Lambda | 1M requests/month | $0.20 per million |
| DynamoDB | 25 WCU, 25 RCU | Pay per request |
| **Total (10K students)** | | **~$0.50/month** |

---

## 🧹 Cleanup

```bash
terraform destroy -auto-approve
```

---

## 📊 What Was Fixed (Summary)

| File | Issue | Fix |
|------|-------|-----|
| dynamodb.tf | `"var.xxx"` (string literal) | `var.xxx` (actual variable) |
| lambda.tf | `"var.function_name"` | `var.function_name` |
| lambda.tf | `"var.runtime"` | `var.runtime` |
| lambda.tf | Wrong role: `lambda_exec_role` | Correct: `lambda_dynamodb_role` |
| lambda.tf | Wrong handler: `index.handler` | Correct: `lambda_function.lambda_handler` |
| iam.tf | Missing CloudWatch permission | Added logs:* permissions |
| api-gateway.tf | Only GET method | Added POST, PUT, DELETE, OPTIONS |
| api-gateway.tf | No deployment/stage | Added both (gives you the URL!) |
| output.tf | Empty | Added API URL + Postman test commands |

---

**Deploy it, test in Postman, and you're good to go!** 🚀

```
Api Gateway flows:-

1. Postman → API Gateway → Lambda → DynamoDB

2. API Gateway:-

Rest Api -> Resource -> Method -> Integration -> Deployment -> Stage
