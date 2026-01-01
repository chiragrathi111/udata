# Terraform Custom VPC Module

## 🏗️ What are Terraform Modules?

**Terraform modules** are containers for multiple resources that are used together. A module consists of a collection of `.tf` files kept together in a directory.

### 📁 Module Structure
```
custom_module_vpc/
├── main.tf              # Root module - calls child module
├── variables.tf          # Root module variables
├── outputs.tf           # Root module outputs
├── provider.tf          # Provider configuration
├── terraform.tfvars     # Variable values
├── module/              # Child module directory
│   ├── main.tf          # Child module resources
│   ├── variables.tf     # Child module variables
│   └── outputs.tf       # Child module outputs
└── README.md           # This file
```

## 🎯 Why Use Modules?

### 1. **Reusability**
- Write once, use multiple times
- Same VPC structure for dev, staging, prod

### 2. **Organization**
- Clean separation of concerns
- Easier to maintain and understand

### 3. **Standardization**
- Consistent infrastructure across environments
- Enforce best practices and security standards

### 4. **Collaboration**
- Teams can share and reuse modules
- Version control for infrastructure components

### 5. **Testing**
- Test modules independently
- Validate infrastructure components

## 🌟 Benefits of This VPC Module

### ✅ **What This Module Creates:**
- **VPC** with custom CIDR block
- **Public Subnets** (3) with internet access
- **Private Subnets** (3) without direct internet access
- **Internet Gateway** for public internet access
- **Route Tables** for traffic routing
- **Route Table Associations** linking subnets to route tables

### ✅ **Key Features:**
- **Multi-AZ deployment** across 3 availability zones
- **Automatic subnet distribution** across AZs
- **DNS support** enabled for hostname resolution
- **Proper tagging** for resource management
- **Flexible CIDR blocks** configurable via variables

## 🚀 Real-World Example

### **Scenario: E-commerce Platform Infrastructure**

Imagine you're building an e-commerce platform that needs:
- **Web servers** in public subnets (accessible from internet)
- **Database servers** in private subnets (secure, no direct internet access)
- **Load balancers** in public subnets
- **Application servers** in private subnets

### **Without Modules (Traditional Way):**
```hcl
# You would need to write 50+ lines of code for each environment
# dev-vpc.tf (50+ lines)
# staging-vpc.tf (50+ lines) 
# prod-vpc.tf (50+ lines)
# Total: 150+ lines of repetitive code
```

### **With This Module (Modern Way):**
```hcl
# dev environment
module \"dev_vpc\" {
  source = \"./module\"
  project_name = \"ecommerce-dev\"
  vpc_cidr = \"10.0.0.0/16\"
  # ... other variables
}

# staging environment  
module \"staging_vpc\" {
  source = \"./module\"
  project_name = \"ecommerce-staging\"
  vpc_cidr = \"10.1.0.0/16\"
  # ... other variables
}

# production environment
module \"prod_vpc\" {
  source = \"./module\"
  project_name = \"ecommerce-prod\"
  vpc_cidr = \"10.2.0.0/16\"
  # ... other variables
}
```

**Result:** 3 complete VPC environments with just 30 lines of code!

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    VPC (10.0.0.0/16)                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ │
│  │   Public AZ-1   │ │   Public AZ-2   │ │   Public AZ-3   │ │
│  │  10.0.1.0/24    │ │  10.0.2.0/24    │ │  10.0.3.0/24    │ │
│  │                 │ │                 │ │                 │ │
│  │ [Load Balancer] │ │ [Web Server]    │ │ [Web Server]    │ │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘ │
│           │                   │                   │         │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ │
│  │  Private AZ-1   │ │  Private AZ-2   │ │  Private AZ-3   │ │
│  │  10.0.11.0/24   │ │  10.0.12.0/24   │ │  10.0.13.0/24   │ │
│  │                 │ │                 │ │                 │ │
│  │ [App Server]    │ │ [Database]      │ │ [Cache]         │ │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘ │
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

## 🛠️ How to Use This Module

### 1. **Configure Variables**
Edit `terraform.tfvars`:
```hcl
region = \"us-east-1\"
project_name = \"my-ecommerce\"
cidr = \"10.0.0.0/16\"
public_subnets = [\"10.0.1.0/24\", \"10.0.2.0/24\", \"10.0.3.0/24\"]
private_subnets = [\"10.0.11.0/24\", \"10.0.12.0/24\", \"10.0.13.0/24\"]
```

### 2. **Deploy Infrastructure**
```bash
terraform init
terraform plan
terraform apply
```

### 3. **View Outputs**
```bash
terraform output
```

## 📋 Module Inputs

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `region` | AWS region | `string` | `us-east-1` |
| `project_name` | Project name for tagging | `string` | `vpc-module` |
| `cidr` | VPC CIDR block | `string` | `10.0.0.0/16` |
| `public_subnets` | Public subnet CIDRs | `list(string)` | `[\"10.0.1.0/24\", ...]` |
| `private_subnets` | Private subnet CIDRs | `list(string)` | `[\"10.0.11.0/24\", ...]` |

## 📤 Module Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | ID of the created VPC |
| `public_subnet_ids` | IDs of public subnets |
| `private_subnet_ids` | IDs of private subnets |
| `internet_gateway_id` | ID of internet gateway |
| `vpc_summary` | Summary of all resources |

## 🔄 Module vs Non-Module Comparison

### **Without Module (Traditional):**
- ❌ 50+ lines of code per environment
- ❌ Copy-paste errors
- ❌ Inconsistent configurations
- ❌ Hard to maintain
- ❌ No reusability

### **With Module (This Approach):**
- ✅ 10 lines of code per environment
- ✅ Consistent and tested
- ✅ Easy to maintain
- ✅ Highly reusable
- ✅ Version controlled

## 🎯 Real-World Use Cases

### 1. **Multi-Environment Setup**
```hcl
# Development
module \"dev_vpc\" { source = \"./module\"; project_name = \"app-dev\" }

# Staging  
module \"staging_vpc\" { source = \"./module\"; project_name = \"app-staging\" }

# Production
module \"prod_vpc\" { source = \"./module\"; project_name = \"app-prod\" }
```

### 2. **Multi-Region Deployment**
```hcl
# US East
module \"us_east_vpc\" { source = \"./module\"; region = \"us-east-1\" }

# US West
module \"us_west_vpc\" { source = \"./module\"; region = \"us-west-2\" }
```

### 3. **Different Sized Networks**
```hcl
# Small environment
module \"small_vpc\" { 
  source = \"./module\"
  cidr = \"10.0.0.0/24\"  # Smaller network
}

# Large environment
module \"large_vpc\" { 
  source = \"./module\"
  cidr = \"10.0.0.0/16\"  # Larger network
}
```

## 🚀 Next Steps

1. **Deploy this module** to understand how it works
2. **Modify variables** to see different configurations
3. **Create additional modules** for EC2, RDS, etc.
4. **Combine modules** to build complete applications
5. **Version your modules** using Git tags
6. **Share modules** with your team via Git repositories

## 🔐 Best Practices

- ✅ Always use descriptive variable names
- ✅ Add comprehensive comments
- ✅ Include input validation
- ✅ Provide meaningful outputs
- ✅ Use consistent naming conventions
- ✅ Version your modules
- ✅ Test modules before using in production

## 🎉 Benefits Summary

| Aspect | Without Modules | With Modules |
|--------|----------------|--------------|
| **Code Reuse** | Copy-paste | Import and configure |
| **Maintenance** | Update each file | Update once, apply everywhere |
| **Consistency** | Manual effort | Automatic |
| **Testing** | Test each environment | Test module once |
| **Collaboration** | Share entire configs | Share modules |
| **Version Control** | File-level | Module-level |

**This VPC module demonstrates the power of Terraform modules - write once, use everywhere, maintain easily!**