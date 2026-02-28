# 📚 Terraform Projects Master Index

Complete guide to all Terraform projects in this repository.

## 🎯 Quick Navigation

### Serverless & Event-Driven
- [api_lambda_sqs_sns_dydb](#api_lambda_sqs_sns_dydb) - Event-driven order processing
- [lambda_apigw_1](#lambda_apigw_1) - Lambda + API Gateway REST API
- [lambda_apigw_2](#lambda_apigw_2) - Lambda + API Gateway (variant)
- [lambda_image](#lambda_image) - S3-triggered file processing
- [lambda_s3_sns](#lambda_s3_sns) - S3 upload email notifications
- [lambda_project](#lambda_project) - Dual-bucket file processor
- [lambda_test](#lambda_test) - Basic Lambda testing
- [image-processing-terraform](#image-processing-terraform) - Image processing with modules

### Multi-Tier Architectures
- [2tier](#2tier) - 2-tier web application (EC2 + RDS)
- [3tier](#3tier) - 3-tier starter template
- [3tier-web-app](#3tier-web-app) - Complete 3-tier with modules
- [aws-3tier-terraform](#aws-3tier-terraform) - 3-tier Flask application

### Networking & VPC
- [vpc_custom_module](#vpc_custom_module) - Custom VPC module
- [custom_module_vpc](#custom_module_vpc) - VPC module with examples
- [vpc_peering](#vpc_peering) - VPC peering setup
- [vpc_transit](#vpc_transit) - Transit Gateway architecture
- [self-security-group](#self-security-group) - Self-referencing security groups

### Deployment Strategies
- [blue_grren_deployment](#blue_grren_deployment) - Blue-Green deployment
- [day17](#day17) - Blue-Green with Lambda

### Static Hosting & CDN
- [webhosting](#webhosting) - S3 + CloudFront static hosting

### Security & IAM
- [iam_feature](#iam_feature) - IAM users, groups, policies
- [kms-demo](#kms-demo) - KMS encryption demo

### Learning Resources
- [Variable](#variable) - Terraform variables guide
- [day18](#day18) - Advanced Lambda patterns
- [day23](#day23) - S3 security monitoring

---

## 📖 Project Details

### api_lambda_sqs_sns_dydb
**Type**: Event-Driven Architecture  
**Services**: API Gateway, Lambda, SQS, SNS, DynamoDB  
**Use Case**: Asynchronous order processing system  
**Key Concepts**: Producer-consumer pattern, message queuing, decoupling  
**Documentation**: EVENT_DRIVEN_ARCHITECTURE_GUIDE.md

### lambda_apigw_1
**Type**: Serverless REST API  
**Services**: Lambda, API Gateway  
**Use Case**: Simple REST API endpoint  
**Key Concepts**: Lambda proxy integration, API Gateway stages  
**Documentation**: README.md

### lambda_image
**Type**: Event-Driven File Processing  
**Services**: S3, Lambda, CloudWatch  
**Use Case**: Automatic file processing on upload  
**Key Concepts**: S3 event notifications, file processing  
**Documentation**: README.md

### lambda_s3_sns
**Type**: Notification System  
**Services**: S3, Lambda, SNS  
**Use Case**: Email alerts on file uploads  
**Key Concepts**: Event notifications, SNS subscriptions  
**Documentation**: README.md

### 2tier
**Type**: Web Application  
**Services**: VPC, EC2, RDS, ALB  
**Use Case**: Flask web app with database  
**Key Concepts**: 2-tier architecture, custom modules  
**Documentation**: README.md, PRACTICAL_GUIDE.md

### 3tier-web-app
**Type**: Production Web Application  
**Services**: VPC, ALB, ASG, RDS, Multi-AZ  
**Use Case**: Scalable 3-tier application  
**Key Concepts**: High availability, auto-scaling, modules  
**Documentation**: README.md

### vpc_custom_module
**Type**: Networking Module  
**Services**: VPC, Subnets, IGW, Route Tables  
**Use Case**: Reusable VPC infrastructure  
**Key Concepts**: Terraform modules, multi-AZ  
**Documentation**: README.md

### vpc_peering
**Type**: Network Connectivity  
**Services**: VPC Peering, Cross-region  
**Use Case**: Connect multiple VPCs  
**Key Concepts**: VPC peering, CIDR planning  
**Documentation**: VPC_PEERING_GUIDE.md

### blue_grren_deployment
**Type**: Deployment Strategy  
**Services**: ALB, ASG, EC2  
**Use Case**: Zero-downtime deployments  
**Key Concepts**: Blue-green deployment, traffic switching  
**Documentation**: README.md

### webhosting
**Type**: Static Website Hosting  
**Services**: S3, CloudFront, OAC  
**Use Case**: Static website with CDN  
**Key Concepts**: S3 hosting, CloudFront distribution  
**Documentation**: COMPLETE_GUIDE.md

### iam_feature
**Type**: Identity & Access Management  
**Services**: IAM Users, Groups, Policies  
**Use Case**: Bulk user management from CSV  
**Key Concepts**: IAM best practices, MFA enforcement  
**Documentation**: README.md

### kms-demo
**Type**: Encryption  
**Services**: KMS  
**Use Case**: Data encryption with envelope encryption  
**Key Concepts**: CMK, data keys, envelope encryption  
**Documentation**: KMS_GUIDE.md

### self-security-group
**Type**: Networking Security  
**Services**: Security Groups  
**Use Case**: Kubernetes cluster security  
**Key Concepts**: Self-referencing security groups  
**Documentation**: README.md

### Variable
**Type**: Learning Resource  
**Services**: N/A  
**Use Case**: Understanding Terraform variables  
**Key Concepts**: Variable types, precedence, validation  
**Documentation**: README.md

---

## 🎓 Learning Path

### Beginner
1. **lambda_test** - Basic Lambda
2. **Variable** - Terraform variables
3. **self-security-group** - Security groups
4. **webhosting** - S3 static hosting

### Intermediate
1. **lambda_apigw_1** - REST API
2. **lambda_s3_sns** - Event notifications
3. **2tier** - Web application
4. **vpc_custom_module** - VPC basics

### Advanced
1. **api_lambda_sqs_sns_dydb** - Event-driven architecture
2. **3tier-web-app** - Production architecture
3. **blue_grren_deployment** - Deployment strategies
4. **vpc_transit** - Transit Gateway

---

## 💡 By Use Case

### Building APIs
- lambda_apigw_1, lambda_apigw_2, api_lambda_sqs_sns_dydb

### File Processing
- lambda_image, lambda_s3_sns, lambda_project, image-processing-terraform

### Web Applications
- 2tier, 3tier-web-app, aws-3tier-terraform

### Networking
- vpc_custom_module, custom_module_vpc, vpc_peering, vpc_transit

### Security
- iam_feature, kms-demo, self-security-group

### Deployment
- blue_grren_deployment, day17

---

## 📊 Complexity Matrix

| Project | Complexity | Services | Time to Deploy |
|---------|-----------|----------|----------------|
| lambda_test | ⭐ | 1 | 2 min |
| lambda_apigw_1 | ⭐⭐ | 2 | 5 min |
| lambda_s3_sns | ⭐⭐ | 3 | 5 min |
| 2tier | ⭐⭐⭐ | 5 | 10 min |
| api_lambda_sqs_sns_dydb | ⭐⭐⭐⭐ | 5 | 10 min |
| 3tier-web-app | ⭐⭐⭐⭐⭐ | 8+ | 15 min |

---

## 🚀 Quick Start Commands

```bash
# Clone and navigate
cd TerraformWithPi/<project-name>

# Initialize
terraform init

# Plan
terraform plan

# Deploy
terraform apply -auto-approve

# Destroy
terraform destroy -auto-approve
```

---

**Complete Terraform learning repository** 🎓
