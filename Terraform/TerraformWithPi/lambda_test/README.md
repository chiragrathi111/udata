# 🧪 Lambda Function Test

## Overview

Basic Lambda function for testing and learning Lambda fundamentals.

## Deploy

```bash
terraform init
terraform apply
```

## Test

```bash
# Invoke Lambda
aws lambda invoke \
  --function-name aws_lambda_test5515 \
  --payload '{"queryStringParameters":{"name":"Alice"}}' \
  response.json

# View response
cat response.json
```

## Response

```json
{
  "statusCode": 200,
  "body": "{\"message\": \"Hello, Alice! Your request was successful.\", \"status\": \"success\"}"
}
```

## Use Cases

- Learning Lambda basics
- Testing Lambda configurations
- Prototyping Lambda functions
- Understanding handler patterns

---

**Simple Lambda for testing** 🧪
