# 🏗️ 3-Tier Web Application on AWS with Terraform

## 📋 Project Overview

This project deploys a **production-ready 3-tier web application** on AWS using Terraform with:
- **Frontend**: Python Flask web interface (Port 3000)
- **Backend**: Python Flask REST API (Port 8080)
- **Database**: PostgreSQL RDS (Port 5432)

## 🏛️ Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    INTERNET (Users)                          │
└────────────────────────┬────────────────────────────────────┘
                         │
                ┌────────▼────────┐
                │ Internet Gateway │
                └────────┬────────┘
                         │
┌────────────────────────┼────────────────────────────────────┐
│ VPC: 10.0.0.0/16       │                                    │
│                        │                                    │
│  ┌─────────────────────▼──────────────────────────┐        │
│  │ PUBLIC TIER (Web Layer)                        │        │
│  │ • Application Load Balancer                    │        │
│  │ • Bastion Host (SSH access)                    │        │
│  │ • NAT Gateways (2 AZs)                        │        │
│  └─────────────────────┬──────────────────────────┘        │
│                        │                                    │
│  ┌─────────────────────▼──────────────────────────┐        │
│  │ FRONTEND PRIVATE TIER (App Layer)              │        │
│  │ • Auto Scaling Group (2-4 instances)           │        │
│  │ • Python Flask Frontend (Port 3000)            │        │
│  │ • Talks to Backend API                         │        │
│  └─────────────────────┬──────────────────────────┘        │
│                        │                                    │
│  ┌─────────────────────▼──────────────────────────┐        │
│  │ BACKEND PRIVATE TIER (API Layer)               │        │
│  │ • Auto Scaling Group (2-6 instances)           │        │
│  │ • Python Flask Backend API (Port 8080)         │        │
│  │ • Talks to Database                            │        │
│  └─────────────────────┬──────────────────────────┘        │
│                        │                                    │
│  ┌─────────────────────▼──────────────────────────┐        │
│  │ DATABASE TIER (Data Layer)                     │        │
│  │ • RDS PostgreSQL 15                            │        │
│  │ • Multi-AZ (Optional)                          │        │
│  │ • Encrypted Storage                            │        │
│  └────────────────────────────────────────────────┘        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
3tier-web-app/
├── README.md                    # This file
├── DEPLOYMENT_GUIDE.md          # Step-by-step deployment
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                 # Root module orchestration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── provider.tf             # AWS provider config
│   ├── terraform.tfvars        # Your configuration
│   └── modules/                # Custom modules
│       ├── vpc/                # VPC, Subnets, IGW, NAT
│       ├── alb/                # Application Load Balancer
│       ├── asg/                # Auto Scaling Groups
│       ├── rds/                # PostgreSQL Database
│       ├── security/           # Security Groups
│       └── iam/                # IAM Roles & Policies
├── application/                # Application code
│   ├── backend/                # Python Flask API
│   │   ├── app.py             # Backend application
│   │   ├── requirements.txt   # Python dependencies
│   │   └── Dockerfile         # Container image
│   └── frontend/               # Python Flask Web
│       ├── app.py             # Frontend application
│       ├── requirements.txt   # Python dependencies
│       ├── templates/         # HTML templates
│       └── Dockerfile         # Container image
└── scripts/                    # Helper scripts
    ├── deploy.sh              # Automated deployment
    ├── destroy.sh             # Cleanup resources
    └── user-data/             # EC2 initialization scripts
        ├── frontend.sh        # Frontend setup
        └── backend.sh         # Backend setup
```

## 🎯 Key Features

### 🔒 Security
- **Private Subnets**: Frontend, Backend, and Database in private subnets
- **Security Groups**: Strict ingress/egress rules
- **Secrets Manager**: Database credentials encrypted
- **Bastion Host**: Secure SSH access to private instances
- **Encrypted Storage**: RDS encryption at rest

### 🚀 High Availability
- **Multi-AZ**: Resources across 2 availability zones
- **Auto Scaling**: Automatic scaling based on CPU usage
- **Load Balancing**: ALB distributes traffic
- **Health Checks**: Automatic unhealthy instance replacement
- **NAT Gateways**: Redundant internet access for private subnets

### 💰 Cost Optimization
- **t3.micro instances**: Free tier eligible
- **Auto Scaling**: Scale down during low traffic
- **Single AZ RDS**: Development mode (Multi-AZ for production)
- **gp3 Storage**: Cost-effective storage

### 📊 Monitoring
- **CloudWatch Logs**: Application and system logs
- **CloudWatch Metrics**: CPU, Memory, Network metrics
- **ALB Metrics**: Request count, latency, errors
- **RDS Metrics**: Database performance

## 🛠️ Technology Stack

| Layer | Technology | Port | Purpose |
|-------|-----------|------|---------|
| **Frontend** | Python Flask | 3000 | Web UI |
| **Backend** | Python Flask | 8080 | REST API |
| **Database** | PostgreSQL 15 | 5432 | Data Storage |
| **Load Balancer** | ALB | 80/443 | Traffic Distribution |
| **Infrastructure** | Terraform | - | IaC |

## 📦 Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** installed (v1.14+)
3. **AWS CLI** configured
4. **Python 3.9+** (for local testing)
5. **Docker** (optional, for containerization)

## 🚀 Quick Start

### 1. Clone and Configure
```bash
cd 3tier-web-app/terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Edit with your settings
```

### 2. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Review deployment plan
terraform plan

# Deploy infrastructure
terraform apply
```

### 3. Access Application
```bash
# Get ALB DNS name
terraform output alb_dns_name

# Access in browser
http://<alb-dns-name>
```

## 🔧 Configuration

### terraform.tfvars
```hcl
# AWS Configuration
region = "us-east-1"
project_name = "3tier-app"
environment = "dev"

# Network Configuration
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

# Database Configuration
db_name = "appdb"
db_username = "admin"
db_instance_class = "db.t3.micro"

# Auto Scaling Configuration
frontend_min_size = 2
frontend_max_size = 4
backend_min_size = 2
backend_max_size = 6
```

## 📊 Resource Costs (Estimated)

| Resource | Type | Monthly Cost (USD) |
|----------|------|-------------------|
| EC2 Instances | 4x t3.micro | ~$30 |
| RDS PostgreSQL | db.t3.micro | ~$15 |
| ALB | 1x ALB | ~$20 |
| NAT Gateways | 2x NAT | ~$65 |
| Data Transfer | Varies | ~$10 |
| **Total** | | **~$140/month** |

**Note**: Use free tier and single AZ for development to reduce costs.

## 🎓 Learning Objectives

This project demonstrates:
1. **3-Tier Architecture**: Separation of concerns
2. **High Availability**: Multi-AZ deployment
3. **Auto Scaling**: Dynamic resource management
4. **Security Best Practices**: Private subnets, security groups
5. **Infrastructure as Code**: Terraform modules
6. **Load Balancing**: Traffic distribution
7. **Database Management**: RDS PostgreSQL
8. **Monitoring**: CloudWatch integration

## 🔍 Troubleshooting

### Common Issues

1. **Permission Errors**
   ```bash
   # Check AWS credentials
   aws sts get-caller-identity
   ```

2. **Port Conflicts**
   ```bash
   # Check security group rules
   terraform state show module.security.aws_security_group.frontend
   ```

3. **Database Connection**
   ```bash
   # Check RDS endpoint
   terraform output rds_endpoint
   ```

## 🧹 Cleanup

```bash
# Destroy all resources
terraform destroy

# Or use cleanup script
../scripts/destroy.sh
```

## 📚 Additional Resources

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## 🤝 Contributing

This is a learning project. Feel free to:
- Add features
- Improve security
- Optimize costs
- Enhance monitoring

## 📄 License

MIT License - Free to use for learning and commercial purposes.

---

**Built with ❤️ for learning AWS and Terraform**