# 🎓 Full-Stack Serverless Student Portal

## What Is This?

A complete web application with **frontend + backend** — fully serverless, zero servers to manage.

- **Frontend**: HTML page hosted on S3, served via CloudFront CDN
- **Backend**: Lambda + API Gateway + DynamoDB

You open a URL in browser → see a Student Portal → add/view/delete students → data saved in DynamoDB.

---

## 🏗️ Architecture (The Full Picture)

```
                         ┌─────────────────────┐
                         │    YOUR BROWSER      │
                         └──────────┬───────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │ (loads page)  │               │ (API calls)
                    ▼               │               ▼
           ┌────────────────┐      │      ┌────────────────┐
           │   CloudFront   │      │      │  API Gateway    │
           │   (CDN)        │      │      │  /students      │
           └───────┬────────┘      │      └───────┬────────┘
                   │               │              │
                   ▼               │              ▼
           ┌────────────────┐      │      ┌────────────────┐
           │   S3 Bucket    │      │      │    Lambda       │
           │  (index.html)  │      │      │  (Python)       │
           └────────────────┘      │      └───────┬────────┘
                                   │              │
                                   │              ▼
                                   │      ┌────────────────┐
                                   │      │   DynamoDB      │
                                   │      │  (students)     │
                                   │      └────────────────┘
                                   │
                         STEP 1: Browser loads page from CloudFront
                         STEP 2: Page's JavaScript calls API Gateway
                         STEP 3: API Gateway triggers Lambda
                         STEP 4: Lambda reads/writes DynamoDB
                         STEP 5: Response flows back to browser
```

---

## 🔄 How Each Piece Works

### 1. S3 Bucket (File Storage)
```
What: Stores your index.html file
Why:  Cheap, reliable file hosting ($0.023/GB)
How:  Terraform uploads index.html to S3 automatically
```
- S3 is **private** (no one can access directly)
- Only CloudFront can read from it (via OAC)

### 2. CloudFront (CDN)
```
What: Delivers your website to users worldwide
Why:  Fast (400+ edge locations), free HTTPS, caching
How:  User hits CloudFront URL → CloudFront fetches from S3 → caches it
```
- First visit: CloudFront gets file from S3 (slow, ~100ms)
- Next visits: CloudFront serves from cache (fast, ~10ms)
- Gives you a URL like: `https://d1234abcd.cloudfront.net`

### 3. OAC (Origin Access Control)
```
What: A "VIP pass" that only CloudFront has
Why:  Keeps S3 private while letting CloudFront read files
How:  CloudFront signs every request to S3 with this pass
```
- Without OAC: Either S3 is public (insecure!) or CloudFront can't read it
- With OAC: S3 stays private, CloudFront has exclusive access ✅

### 4. API Gateway (API Router)
```
What: Receives HTTP requests and routes to Lambda
Why:  Gives you a public URL for your API
How:  POST /students → Lambda creates student
      GET /students  → Lambda returns all students
```

### 5. Lambda (Backend Logic)
```
What: Python function that handles CRUD operations
Why:  Runs only when called, scales automatically
How:  Reads httpMethod → does DynamoDB operation → returns JSON
```

### 6. DynamoDB (Database)
```
What: NoSQL database storing student records
Why:  Serverless, auto-scales, pay-per-request
How:  Each student = one item with studentId as primary key
```

---

## 📁 File Structure

```
lambda_api-gateway_dynamodb_s3_cloudfront/
│
│── provider.tf           # Terraform + AWS provider config
│── variable.tf           # All input variables
│── terraform.tfvars      # Your values (region, names)
│
│── dynamodb.tf           # DynamoDB table (students)
│── iam.tf                # IAM role + policy for Lambda
│── lambda.tf             # Lambda function + CloudWatch logs
│── lambda_function.py    # Python CRUD logic (your code)
│── api-gateway.tf        # API Gateway (GET/POST/PUT/DELETE/OPTIONS)
│
│── s3.tf                 # S3 bucket + policy + upload index.html
│── cloudfront.tf         # CloudFront CDN + OAC
│── index.html            # Frontend HTML (your code)
│
│── output.tf             # URLs you need after deployment
└── README.md             # This file
```

---

## 🚀 Deploy

```bash
cd lambda_api-gateway_dynamodb_s3_cloudfront

terraform init
terraform apply -auto-approve

# You'll see these outputs:
# frontend_url = "https://d1234abcd.cloudfront.net"   ← Open in browser
# api_url      = "https://xyz.execute-api.../students" ← Use in Postman
```

**⚠️ CloudFront takes 5-10 minutes to deploy. Be patient!**

---

## 🧪 Testing

### Test 1: Open Frontend in Browser
```
Copy the frontend_url from terraform output
Paste in browser
You should see the Student Portal page
```

### Test 2: Add a Student (via Browser)
```
Fill in: Name, Email, Course, Marks
Click "Add Student"
Student appears in the table below
```

### Test 3: Test API in Postman
```
POST https://xyz.execute-api.../prod/students
Body:
{
  "name": "Chirag Rathi",
  "email": "chirag@example.com",
  "course": "AWS DevOps",
  "marks": 95
}
```

### Test 4: Verify in DynamoDB
```bash
aws dynamodb scan --table-name students --region us-east-1
```

---

## 🐛 Troubleshooting

### "Access Denied" when opening CloudFront URL
- CloudFront is still deploying (wait 5-10 min)
- Check: `aws cloudfront get-distribution --id <dist-id> | grep Status`
- Should say `Deployed`, not `InProgress`

### Frontend loads but API calls fail
- Open browser DevTools (F12) → Console tab → look for errors
- Most likely CORS issue → OPTIONS method is configured ✅
- Check API URL in index.html matches terraform output

### "Internal Server Error" from API
```bash
# Check Lambda logs
aws logs tail /aws/lambda/StudentManagementFunction-lambda --follow
```

### Frontend shows old content after code change
```bash
# Clear CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"
```

### Want to update index.html?
```bash
# Edit index.html, then:
terraform apply -auto-approve
# Then clear cache (above command)
```

---

## 💰 Cost

| Service | Free Tier | After Free Tier |
|---------|-----------|-----------------|
| S3 | 5GB storage | $0.023/GB |
| CloudFront | 1TB transfer/month | $0.085/GB |
| API Gateway | 1M requests/month | $3.50/million |
| Lambda | 1M requests/month | $0.20/million |
| DynamoDB | 25GB + 25 WCU/RCU | Pay per request |
| **Total (small usage)** | **$0** | **~$1-2/month** |

---

## 🎓 Interview Questions

### Q: Why CloudFront in front of S3? Why not make S3 public?

**Answer**: Three reasons:
1. **Security**: S3 stays private. No one can access files directly
2. **Performance**: CloudFront caches at 400+ edge locations worldwide. User in Mumbai gets file from Mumbai edge, not from US
3. **HTTPS**: CloudFront gives free HTTPS. S3 website hosting only supports HTTP

### Q: What is OAC and why do you need it?

**Answer**: OAC (Origin Access Control) is like a VIP pass. S3 bucket is locked (private). CloudFront shows this pass to S3 and says "I'm authorized, give me the file." Without OAC, you'd have to make S3 public (bad security) or CloudFront can't read files.

### Q: How does the frontend talk to the backend?

**Answer**: The index.html has JavaScript that makes `fetch()` calls to the API Gateway URL. When you click "Add Student", JavaScript sends a POST request to `https://api-gateway-url/prod/students`. API Gateway routes it to Lambda, Lambda writes to DynamoDB, response comes back to the browser.

### Q: What happens when you update index.html?

**Answer**: Run `terraform apply` to upload new file to S3. But CloudFront still serves the cached old version (up to 1 hour). You need to create a CloudFront invalidation (`aws cloudfront create-invalidation --paths "/*"`) to clear the cache and serve the new file.

### Q: How does Terraform inject the API URL into index.html?

**Answer**: In s3.tf, we use `replace()` function:
```hcl
content = replace(
  file("index.html"),
  "https://YOUR_API_URL/prod/students",
  "${aws_api_gateway_stage.api_stage.invoke_url}/students"
)
```
Terraform reads index.html, replaces the placeholder with the real API Gateway URL, and uploads the modified version to S3. So you never need to manually paste the URL.

---

## 🧹 Cleanup

```bash
# Empty S3 bucket first (required before deletion)
aws s3 rm s3://$(terraform output -raw s3_bucket_name) --recursive

# Destroy everything
terraform destroy -auto-approve
```

**Note**: CloudFront takes 10-15 minutes to delete. Be patient.

---

## 📊 What Was Fixed (Summary)

| File | Issue | Fix |
|------|-------|-----|
| api-gateway.tf | `aws_lambda_function.student_management` (doesn't exist) | Changed to `aws_lambda_function.lambda_function` |
| s3.tf | `aws_s3_bucket.s3_upload_bucket` (doesn't exist) | Rewrote with correct `aws_s3_bucket.frontend` |
| s3.tf | No bucket policy for CloudFront | Added OAC-based bucket policy |
| s3.tf | index.html not uploaded to S3 | Added `aws_s3_object` with API URL injection |
| cloudfront.tf | Empty file | Created full CloudFront + OAC configuration |
| output.tf | Empty file | Added frontend_url, api_url, next_steps |
| lambda_function.py | Hardcoded `region_name='ap-south-1'` | Removed (Lambda auto-detects region) |
| iam.tf | Typo `lmbda_dynamodb_attachment` | Fixed to `lambda_dynamodb_attachment` |

---

**Deploy it, open the CloudFront URL in browser, and you have a working full-stack app!** 🚀
