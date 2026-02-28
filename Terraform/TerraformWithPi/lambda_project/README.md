# 🖼️ Lambda S3 Image Processor

## Overview

S3-triggered Lambda function for file processing with dual-bucket architecture.

## Architecture

```
Upload Bucket → Lambda → Processed Bucket
```

## Deploy

```bash
terraform init
terraform apply
```

## Test

```bash
# Upload file
BUCKET=$(terraform output -raw upload_bucket_name)
aws s3 cp test.jpg s3://$BUCKET/

# Check processed bucket
PROCESSED=$(terraform output -raw processed_bucket_name)
aws s3 ls s3://$PROCESSED/
```

## Features

- Automatic file processing on upload
- Dual-bucket architecture (upload/processed)
- Versioning enabled
- Encryption at rest
- CloudWatch logging

## Use Cases

- Image processing/resizing
- Document conversion
- Data transformation
- File validation
- Metadata extraction

---

**S3-triggered file processing** 🖼️
