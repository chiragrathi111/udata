# Lambda API Gateway with POST Endpoint

Complete Terraform setup for AWS Lambda with API Gateway supporting both GET and POST methods.

## Project Structure
```
lambda_apigw_2/
├── lambda/
│   └── hello.py          # Lambda function code
├── apigw.tf             # API Gateway configuration
├── iam.tf               # IAM roles and policies
├── lambda.tf            # Lambda function configuration
├── outputs.tf           # Output values
├── provider.tf          # Terraform providers
├── terraform.tfvars     # Variable values
├── variable.tf          # Variable definitions
└── README.md           # This file
```

## API Endpoints

### GET /hello
- **URL**: `{base_url}/hello`
- **Method**: GET
- **Query Parameters**: `name` (optional)
- **Example**: `GET /hello?name=John`

### POST /users
- **URL**: `{base_url}/users`
- **Method**: POST
- **Headers**: `Content-Type: application/json`
- **Body**: `{"name": "John Doe", "age": 25}`

## Setup Instructions

1. **Initialize Terraform**
   ```bash
   cd lambda_apigw_2
   terraform init
   ```

2. **Plan Deployment**
   ```bash
   terraform plan
   ```

3. **Deploy Infrastructure**
   ```bash
   terraform apply
   ```

4. **Get Endpoint URLs**
   ```bash
   # Get all outputs
   terraform output
   
   # Get specific endpoint
   terraform output users_endpoint_url
   
   # Get clean URL for Postman
   terraform output -raw users_endpoint_url
   ```

## Postman Testing

### GET Request
- Method: GET
- URL: Copy from `terraform output api_endpoint_url`
- Optional query: `?name=YourName`

### POST Request
- Method: POST
- URL: Copy from `terraform output users_endpoint_url`
- Headers: `Content-Type: application/json`
- Body (raw JSON):
  ```json
  {
    "name": "John Doe",
    "age": 25
  }
  ```

## Cleanup
```bash
terraform destroy
```

## Features
- ✅ GET /hello endpoint with query parameters
- ✅ POST /users endpoint with JSON validation
- ✅ Request validation and error handling
- ✅ CORS support
- ✅ CloudWatch logging
- ✅ Complete Terraform automation