# 2-Tier Architecture with Terraform Modules

## 🏗️ What is 2-Tier Architecture?

**2-Tier Architecture** separates an application into two layers:
1. **Presentation Tier** (Web Layer) - Web servers in public subnets
2. **Data Tier** (Database Layer) - Database servers in private subnets

## 📁 Project Structure

```
2tier/
├── main.tf              # Root module - calls child modules
├── variables.tf         # Root module variables
├── outputs.tf          # Root module outputs
├── provider.tf         # Provider configuration
├── terraform.tfvars    # Variable values
├── module/             # Child modules directory
│   ├── vpc/            # VPC module
│   │   ├── main.tf     # VPC, subnets, IGW, NAT
│   │   ├── variables.tf # VPC variables
│   │   ├── outputs.tf  # VPC outputs
│   │   └── data.tf     # Availability zones
│   ├── sg/             # Security Groups module
│   │   ├── main.tf     # Web and DB security groups
│   │   ├── variables.tf # SG variables
│   │   └── outputs.tf  # SG outputs
│   ├── ec2/            # EC2 module
│   │   ├── main.tf     # Web servers
│   │   ├── variables.tf # EC2 variables
│   │   └── templates/  # User data scripts
│   ├── rds/            # RDS module
│   │   ├── main.tf     # Database servers
│   │   └── variables.tf # RDS variables
│   └── ssm/            # SSM module
│       ├── main.tf     # Parameter store for secrets
│       └── variables.tf # SSM variables
└── README.md           # This file
```

## 🎯 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    VPC (10.0.0.0/16)                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              Public Subnet (10.0.1.0/24)               │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │ │
│  │  │ Web Server 1│    │ Web Server 2│    │Load Balancer│  │ │
│  │  │   (EC2)     │    │   (EC2)     │    │   (ALB)     │  │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              │                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │            Private Subnets (10.0.2.0/24, 10.0.3.0/24) │ │
│  │                                                         │ │
│  │     ┌─────────────┐              ┌─────────────┐        │ │
│  │     │  Database   │              │  Database   │        │ │
│  │     │   Primary   │◄────────────►│   Standby   │        │ │
│  │     │   (RDS)     │              │   (RDS)     │        │ │
│  │     └─────────────┘              └─────────────┘        │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────────────┐
                    │ Internet Gateway│
                    └─────────────────┘
                              │
                         ┌─────────┐
                         │Internet │
                         └─────────┘
```

## 🔄 Modules vs Non-Modules Comparison

### **❌ Without Modules (Traditional Approach):**

**Single File Approach:**
```hcl
# main.tf (200+ lines)
resource "aws_vpc" "main" { ... }
resource "aws_subnet" "public" { ... }
resource "aws_subnet" "private1" { ... }
resource "aws_subnet" "private2" { ... }
resource "aws_internet_gateway" "igw" { ... }
resource "aws_nat_gateway" "nat" { ... }
resource "aws_security_group" "web" { ... }
resource "aws_security_group" "db" { ... }
resource "aws_instance" "web1" { ... }
resource "aws_instance" "web2" { ... }
resource "aws_db_instance" "database" { ... }
# ... 50+ more resources
```

**Problems:**
- ❌ **200+ lines** in single file
- ❌ **Hard to maintain** and debug
- ❌ **No reusability** - copy-paste for different environments
- ❌ **Difficult collaboration** - merge conflicts
- ❌ **No testing** of individual components
- ❌ **Inconsistent naming** and configurations

### **✅ With Modules (Modern Approach):**

**Root Module:**
```hcl
# main.tf (50 lines)
module "vpc" { source = "./module/vpc" }
module "sg" { source = "./module/sg" }
module "ec2" { source = "./module/ec2" }
module "rds" { source = "./module/rds" }
module "ssm" { source = "./module/ssm" }
```

**Benefits:**
- ✅ **Clean organization** - each component in its own module
- ✅ **Reusable** - same modules for dev, staging, prod
- ✅ **Easy maintenance** - update one module, affects all environments
- ✅ **Team collaboration** - different teams work on different modules
- ✅ **Independent testing** - test each module separately
- ✅ **Consistent standards** - enforced through modules

## 🚀 Real-World Example: E-commerce Platform

### **Scenario:** You need to deploy the same 2-tier architecture for:
- **Development** environment
- **Staging** environment  
- **Production** environment

### **Without Modules:**
```hcl
# dev-main.tf (200+ lines)
resource "aws_vpc" "dev_vpc" { cidr_block = "10.0.0.0/16" }
resource "aws_subnet" "dev_public" { ... }
# ... 50+ more resources

# staging-main.tf (200+ lines) 
resource "aws_vpc" "staging_vpc" { cidr_block = "10.1.0.0/16" }
resource "aws_subnet" "staging_public" { ... }
# ... 50+ more resources (copy-paste)

# prod-main.tf (200+ lines)
resource "aws_vpc" "prod_vpc" { cidr_block = "10.2.0.0/16" }
resource "aws_subnet" "prod_public" { ... }
# ... 50+ more resources (copy-paste)
```
**Total: 600+ lines of repetitive code!**

### **With Modules:**
```hcl
# dev/main.tf (10 lines)
module "dev_infrastructure" {
  source = "../modules/2tier"
  environment = "dev"
  vpc_cidr = "10.0.0.0/16"
}

# staging/main.tf (10 lines)
module "staging_infrastructure" {
  source = "../modules/2tier"
  environment = "staging"
  vpc_cidr = "10.1.0.0/16"
}

# prod/main.tf (10 lines)
module "prod_infrastructure" {
  source = "../modules/2tier"
  environment = "prod"
  vpc_cidr = "10.2.0.0/16"
}
```
**Total: 30 lines of code for 3 complete environments!**

## 📊 Benefits Comparison

| Aspect | Without Modules | With Modules |
|--------|----------------|--------------|
| **Code Lines** | 600+ lines | 30 lines |
| **Maintenance** | Update 3 files | Update 1 module |
| **Consistency** | Manual effort | Automatic |
| **Testing** | Test 3 environments | Test 1 module |
| **Collaboration** | Merge conflicts | Clean separation |
| **Reusability** | Copy-paste errors | Import and configure |
| **Standards** | Inconsistent | Enforced |

## 🛠️ How to Use This 2-Tier Module

### 1. **Deploy Infrastructure**
```bash
cd 2tier
terraform init
terraform plan
terraform apply
```

### 2. **View Resources Created**
```bash
terraform output
```

### 3. **Access Your Application**
- **Web Servers**: Available via public IP addresses
- **Database**: Accessible only from web servers (secure)
- **Load Balancer**: Distributes traffic across web servers

## 🔧 Module Components

### **VPC Module** (`./module/vpc/`)
- Creates isolated network environment
- Public subnet for web servers
- Private subnets for databases
- Internet Gateway for public access
- NAT Gateway for private subnet internet access

### **Security Groups Module** (`./module/sg/`)
- Web SG: Allows HTTP (80), HTTPS (443), SSH (22)
- DB SG: Allows database port (3306) only from web SG

### **EC2 Module** (`./module/ec2/`)
- Web servers in public subnet
- Auto-scaling group for high availability
- User data script for application setup

### **RDS Module** (`./module/rds/`)
- MySQL/PostgreSQL database in private subnet
- Multi-AZ deployment for high availability
- Automated backups and maintenance

### **SSM Module** (`./module/ssm/`)
- Secure parameter store for database passwords
- Environment-specific configuration

## 🎯 Use Cases

### **1. Multi-Environment Deployment**
```hcl
# Development
module "dev_2tier" {
  source = "./module"
  environment = "dev"
  instance_type = "t3.micro"  # Smaller instances
}

# Production
module "prod_2tier" {
  source = "./module"
  environment = "prod"
  instance_type = "t3.large"  # Larger instances
}
```

### **2. Multi-Region Deployment**
```hcl
# US East
module "us_east_2tier" {
  source = "./module"
  providers = { aws = aws.us_east }
}

# US West
module "us_west_2tier" {
  source = "./module"
  providers = { aws = aws.us_west }
}
```

### **3. Different Application Stacks**
```hcl
# E-commerce Application
module "ecommerce_2tier" {
  source = "./module"
  project_name = "ecommerce"
  db_name = "ecommerce_db"
}

# Blog Application
module "blog_2tier" {
  source = "./module"
  project_name = "blog"
  db_name = "blog_db"
}
```

## 🚀 Quick Start

```bash
# 1. Configure variables in terraform.tfvars
# 2. Initialize and deploy
terraform init
terraform plan
terraform apply

# 3. Get outputs
terraform output

# 4. Access your 2-tier application
# Web servers will be accessible via public IPs
# Database will be secure in private subnets
```

## 🔐 Security Features

- ✅ **Network Isolation**: Web and DB in separate subnets
- ✅ **Security Groups**: Restrictive access rules
- ✅ **Private Database**: No direct internet access
- ✅ **Encrypted Storage**: Database encryption at rest
- ✅ **Secret Management**: Passwords stored in SSM Parameter Store

## 💰 Cost Optimization

- **Development**: Use smaller instance types (t3.micro)
- **Production**: Use appropriate instance types (t3.medium+)
- **Auto-scaling**: Scale based on demand
- **Reserved Instances**: For predictable workloads

## 🎉 Module Advantages Summary

**This 2-tier module approach gives you:**
- **Reusable Infrastructure**: Write once, deploy anywhere
- **Consistent Architecture**: Same structure across environments
- **Easy Maintenance**: Update modules, not individual resources
- **Team Collaboration**: Different teams can work on different modules
- **Version Control**: Track changes at module level
- **Testing**: Test modules independently before deployment

**Perfect for building scalable, maintainable 2-tier applications!**