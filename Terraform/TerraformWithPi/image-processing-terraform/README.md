# 🖼️ AWS Image Processing Pipeline with Terraform

A complete serverless image processing pipeline built with AWS services and managed with Terraform. This project automatically processes uploaded images into multiple variations and provides comprehensive monitoring and alerting.

## 📋 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [How It Works](#-how-it-works)
- [Monitoring & Alerts](#-monitoring--alerts)
- [Benefits](#-benefits)
- [Drawbacks & Limitations](#-drawbacks--limitations)
- [Cost Optimization](#-cost-optimization)
- [Troubleshooting](#-troubleshooting)
- [Resume Points](#-resume-points)

## 🏗️ Architecture Overview

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   User      │    │   Upload    │    │   Lambda    │    │  Processed  │
│  Uploads    │───▶│   S3        │───▶│  Function   │───▶│   S3        │
│   Image     │    │   Bucket    │    │             │    │   Bucket    │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                          │                   │
                          │                   ▼
                          │            ┌─────────────┐
                          │            │ CloudWatch  │
                          │            │    Logs     │
                          │            └─────────────┘
                          │                   │
                          │                   ▼
                          │            ┌─────────────┐    ┌─────────────┐
                          │            │ CloudWatch  │───▶│     SNS     │
                          │            │   Alarms    │    │   Topics    │
                          │            └─────────────┘    └─────────────┘
                          │                                      │
                          │                                      ▼
                          │                               ┌─────────────┐
                          └──────────────────────────────▶│    Email    │
                                                          │ Notifications│
                                                          └─────────────┘
```

## ✨ Features

### 🖼️ Image Processing
- **5 Image Variations**: Automatically creates 5 different versions of each uploaded image:
  1. **Same**: Original image (unchanged)
  2. **Small**: Logo size (100x100px) - Perfect for thumbnails
  3. **Compressed**: Medium size (500x500px) - Balanced quality and size
  4. **Zoom**: Large size (1000x1000px) - High resolution display
  5. **Gray**: Grayscale version - Artistic/professional use

### 🔒 Security & Compliance
- **Encrypted Storage**: All S3 buckets use server-side encryption
- **Private Buckets**: No public access allowed
- **IAM Best Practices**: Least privilege access for all resources
- **Versioning**: S3 versioning enabled for data protection

### 📊 Monitoring & Alerting
- **Real-time Monitoring**: CloudWatch dashboards and metrics
- **Smart Alerts**: Different notification levels (Critical/Normal)
- **Performance Tracking**: Lambda duration, throttles, and error monitoring
- **Custom Metrics**: Processing success rates and image counts

### 💰 Cost Optimization
- **Lifecycle Policies**: Automatic transition to cheaper storage classes
- **Efficient Processing**: Optimized Lambda function with proper memory allocation
- **Pay-per-use**: Only pay for actual processing and storage used

## 🔧 Prerequisites

Before you begin, ensure you have:

1. **AWS Account** with appropriate permissions
2. **Terraform** installed (version ≥ 1.0)
3. **AWS CLI** configured with your credentials
4. **Python 3.9+** for Lambda function development
5. **Valid email address** for notifications

### Required AWS Permissions
Your AWS user/role needs permissions for:
- S3 (buckets, objects, notifications)
- Lambda (functions, layers, permissions)
- IAM (roles, policies)
- CloudWatch (logs, alarms, dashboards)
- SNS (topics, subscriptions)

## 🚀 Quick Start

### 1. Clone and Configure

```bash
# Clone the repository
git clone <your-repo-url>
cd image-processing-terraform

# Configure your settings
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Edit with your email and preferences
```

### 2. Prepare Lambda Package

```bash
# Create Lambda deployment package
cd lambda
zip -r ../lambda.zip image_processor.py
cd ..
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

### 4. Confirm Email Subscription

After deployment:
1. Check your email for SNS subscription confirmations
2. Click \"Confirm subscription\" in both emails (Critical and Normal alerts)

### 5. Test the Pipeline

```bash
# Upload a test image to the upload bucket
aws s3 cp test-image.jpg s3://YOUR-UPLOAD-BUCKET-NAME/

# Check processed images
aws s3 ls s3://YOUR-PROCESSED-BUCKET-NAME/ --recursive
```

## 📁 Project Structure

```
image-processing-terraform/
├── main.tf                 # Root module - orchestrates all components
├── variables.tf            # Input variables and validation
├── outputs.tf             # Output values after deployment
├── provider.tf            # AWS provider configuration
├── terraform.tfvars       # Your configuration values
├── lambda/
│   └── image_processor.py  # Lambda function code
├── module/
│   ├── s3/                # S3 bucket module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── lambda/            # Lambda function module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── create_pillow_layer.py
│   ├── cloudwatch/        # Monitoring module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── sns/               # Notification module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md              # This file
```

## 🔄 How It Works

### Step-by-Step Process

1. **Image Upload**: User uploads an image to the upload S3 bucket
2. **Trigger**: S3 event notification triggers the Lambda function
3. **Processing**: Lambda function:
   - Downloads the original image
   - Validates file format (JPEG, PNG, JPG, WEBP)
   - Creates 5 different variations
   - Uploads processed images to the processed bucket
   - Logs all activities to CloudWatch
4. **Monitoring**: CloudWatch analyzes logs and triggers alarms
5. **Notifications**: SNS sends email alerts based on processing results

### Image Variations Created

| Variation | Size | Purpose | Use Case |
|-----------|------|---------|----------|
| Same | Original | Backup/Archive | Original quality preservation |
| Small | 100x100px | Thumbnails | Website thumbnails, avatars |
| Compressed | 500x500px | Web Display | Blog posts, galleries |
| Zoom | 1000x1000px | High-Res | Print, detailed viewing |
| Gray | Original (B&W) | Artistic | Professional photography, design |

## 📊 Monitoring & Alerts

### CloudWatch Alarms

1. **Critical Errors**: Triggers when Lambda encounters errors
2. **Processing Success**: Confirms successful image processing
3. **Lambda Duration**: Monitors function execution time
4. **Lambda Throttles**: Detects when function is rate-limited

### Notification Types

- **Critical Alerts**: Errors, throttles, performance issues
- **Normal Alerts**: Successful processing confirmations

### Dashboard Metrics

- Image processing success/failure rates
- Lambda performance metrics
- Processing volume over time
- Error trends and patterns

## ✅ Benefits

### Technical Benefits
- **Serverless Architecture**: No server management required
- **Auto-scaling**: Handles any volume of images automatically
- **High Availability**: Built on AWS managed services (99.9%+ uptime)
- **Cost-Effective**: Pay only for what you use
- **Secure**: Enterprise-grade security with encryption and access controls

### Business Benefits
- **Faster Time-to-Market**: Ready-to-use image processing pipeline
- **Reduced Development Costs**: No need to build from scratch
- **Operational Efficiency**: Automated monitoring and alerting
- **Scalability**: Grows with your business needs
- **Compliance Ready**: Built with security best practices

### Developer Benefits
- **Infrastructure as Code**: Version-controlled, repeatable deployments
- **Modular Design**: Easy to customize and extend
- **Comprehensive Logging**: Easy debugging and troubleshooting
- **Modern Stack**: Uses latest AWS services and best practices

## ⚠️ Drawbacks & Limitations

### Technical Limitations
- **Cold Start Latency**: First Lambda invocation may be slower
- **File Size Limits**: Lambda has 512MB temporary storage limit
- **Processing Time**: 15-minute maximum execution time per image
- **Supported Formats**: Limited to JPEG, PNG, JPG, WEBP

### Cost Considerations
- **Storage Costs**: Multiple image variations increase storage usage
- **Data Transfer**: Costs for downloading/uploading large images
- **Lambda Costs**: Charges based on execution time and memory usage

### Operational Challenges
- **Monitoring Complexity**: Multiple services to monitor
- **Debugging**: Distributed system can be harder to troubleshoot
- **Dependency Management**: Requires managing Pillow library layer

## 💰 Cost Optimization

### Implemented Optimizations
- **S3 Lifecycle Policies**: Automatic transition to cheaper storage
- **Right-sized Lambda**: Optimized memory allocation
- **Efficient Image Processing**: Optimized compression settings
- **Log Retention**: 14-day CloudWatch log retention

### Additional Cost-Saving Tips
- **Monitor Usage**: Regular review of CloudWatch metrics
- **Cleanup Old Images**: Implement deletion policies for old processed images
- **Optimize Image Sizes**: Consider reducing variation sizes based on usage
- **Use Reserved Capacity**: For predictable workloads

## 🔧 Troubleshooting

### Common Issues

#### Lambda Function Errors
```bash
# Check Lambda logs
aws logs describe-log-groups --log-group-name-prefix \"/aws/lambda/image-processing\"
aws logs get-log-events --log-group-name \"/aws/lambda/YOUR-FUNCTION-NAME\"
```

#### S3 Permission Issues
- Verify IAM roles have correct S3 permissions
- Check bucket policies and ACLs
- Ensure Lambda has access to both buckets

#### Email Notifications Not Working
- Confirm SNS subscription in email
- Check SNS topic policies
- Verify CloudWatch alarm configurations

### Debug Commands

```bash
# Check Terraform state
terraform show

# Validate configuration
terraform validate

# Check AWS resources
aws s3 ls  # List all buckets
aws lambda list-functions  # List Lambda functions
aws sns list-topics  # List SNS topics
```

## 🎯 Resume Points

This project demonstrates several key skills valuable for cloud engineering roles:

### Technical Skills Demonstrated
- **Infrastructure as Code**: Terraform expertise with modules and best practices
- **Serverless Architecture**: AWS Lambda, S3, CloudWatch integration
- **Monitoring & Alerting**: Comprehensive observability implementation
- **Security**: IAM roles, encryption, least privilege access
- **Python Development**: Image processing with PIL/Pillow
- **DevOps Practices**: Automated deployment, version control

### AWS Services Mastery
- **Compute**: AWS Lambda (serverless functions)
- **Storage**: S3 (object storage, lifecycle policies)
- **Monitoring**: CloudWatch (logs, metrics, alarms, dashboards)
- **Notifications**: SNS (topics, subscriptions)
- **Security**: IAM (roles, policies, permissions)

### Project Highlights for Resume
- Built a **production-ready serverless image processing pipeline**
- Implemented **comprehensive monitoring and alerting** system
- Designed **cost-optimized architecture** with lifecycle policies
- Created **reusable Terraform modules** for infrastructure deployment
- Demonstrated **security best practices** with encryption and access controls

### Key Metrics to Mention
- **5 image variations** processed automatically per upload
- **Sub-second processing** for typical image sizes
- **99.9% availability** using AWS managed services
- **Cost-optimized** with automatic storage class transitions
- **Fully automated** deployment with Terraform

---

## 📞 Support

For questions or issues:
1. Check the [Troubleshooting](#-troubleshooting) section
2. Review AWS CloudWatch logs
3. Validate Terraform configuration
4. Check AWS service limits and quotas

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Built with ❤️ using AWS and Terraform**