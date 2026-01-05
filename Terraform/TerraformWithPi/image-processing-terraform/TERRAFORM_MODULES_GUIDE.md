# 📚 TERRAFORM CUSTOM MODULES - Complete Guide

## 🎯 What are Custom Modules?

**Custom Modules** are reusable pieces of Terraform configuration that you create to organize and package related resources together. Think of them as "functions" in programming - you write them once and use them multiple times.

## 🤔 Why Use Custom Modules?

### ❌ **Without Modules (Bad Practice)**
```hcl
# main.tf - Everything in one file (MESSY!)
resource "aws_s3_bucket" "upload" {
  bucket = "my-upload-bucket"
}

resource "aws_s3_bucket_versioning" "upload" {
  bucket = aws_s3_bucket.upload.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_encryption" "upload" {
  bucket = aws_s3_bucket.upload.id
  # ... more config
}

resource "aws_lambda_function" "processor" {
  # ... lambda config
}

resource "aws_iam_role" "lambda_role" {
  # ... IAM config
}

# 200+ lines of mixed resources = NIGHTMARE TO MAINTAIN!
```

### ✅ **With Modules (Best Practice)**
```hcl
# main.tf - Clean and organized
module "s3_bucket" {
  source = "./module/s3"
  
  bucket_name = "my-upload-bucket"
  bucket_purpose = "upload"
}

module "lambda_processor" {
  source = "./module/lambda"
  
  function_name = "image-processor"
  bucket_arn = module.s3_bucket.bucket_arn
}

# Only 20 lines - EASY TO READ AND MAINTAIN!
```

## 🏗️ Module Structure in Our Project

```
image-processing-terraform/
├── main.tf                    # ROOT MODULE (orchestrator)
├── variables.tf               # Root module inputs
├── outputs.tf                 # Root module outputs
└── module/                    # CUSTOM MODULES
    ├── s3/                    # S3 Custom Module
    │   ├── main.tf           # S3 resources
    │   ├── variables.tf      # S3 inputs
    │   └── outputs.tf        # S3 outputs
    ├── lambda/               # Lambda Custom Module
    │   ├── main.tf           # Lambda resources
    │   ├── variables.tf      # Lambda inputs
    │   └── outputs.tf        # Lambda outputs
    ├── cloudwatch/           # CloudWatch Custom Module
    └── sns/                  # SNS Custom Module
```

## 📋 Root Module vs Custom Module

| Aspect | Root Module | Custom Module |
|--------|-------------|---------------|
| **Location** | Project root directory | `./module/` subdirectory |
| **Purpose** | Orchestrates everything | Handles specific functionality |
| **Files** | `main.tf`, `variables.tf`, `outputs.tf` | Same structure |
| **Execution** | `terraform apply` runs here | Called by root module |
| **State** | Manages Terraform state | Resources tracked in root state |

## 🔍 Detailed Example: S3 Custom Module

### 📁 **Module Structure**
```
module/s3/
├── main.tf       # S3 resources definition
├── variables.tf  # Input parameters
└── outputs.tf    # Return values
```

### 📝 **module/s3/variables.tf** (Module Inputs)
```hcl
# =============================================================================
# S3 MODULE VARIABLES - What the module needs from outside
# =============================================================================

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  # This is REQUIRED - no default value
}

variable "bucket_purpose" {
  description = "Purpose of the bucket (upload or processed)"
  type        = string
  default     = "general"  # This is OPTIONAL - has default
}

variable "lambda_arn" {
  description = "ARN of Lambda function (null if no trigger needed)"
  type        = string
  default     = null  # OPTIONAL - can be null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}  # OPTIONAL - empty map default
}
```

### 🏗️ **module/s3/main.tf** (Module Resources)
```hcl
# =============================================================================
# S3 MODULE RESOURCES - What the module creates
# =============================================================================

# Main S3 bucket
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name  # Using input variable
  
  tags = merge(var.tags, {  # Combining input tags with local tags
    Name    = var.bucket_name
    Purpose = var.bucket_purpose
  })
}

# Enable versioning for data protection
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id  # Reference to bucket above
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Conditional Lambda notification (only if lambda_arn provided)
resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.this.id

  dynamic "lambda_function" {
    for_each = var.lambda_arn != null ? [1] : []  # Conditional creation
    content {
      lambda_function_arn = var.lambda_arn
      events              = ["s3:ObjectCreated:*"]
    }
  }
}
```

### 📤 **module/s3/outputs.tf** (Module Outputs)
```hcl
# =============================================================================
# S3 MODULE OUTPUTS - What the module returns
# =============================================================================

output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_id" {
  description = "ID of the created S3 bucket"
  value       = aws_s3_bucket.this.id
}
```

### 🎯 **Root Module Usage** (main.tf)
```hcl
# =============================================================================
# HOW TO USE THE CUSTOM MODULE
# =============================================================================

# Upload bucket with Lambda trigger
module "upload_bucket" {
  source = "./module/s3"  # Path to custom module
  
  # Required inputs
  bucket_name = "image-processing-upload-${random_string.bucket_suffix.result}"
  
  # Optional inputs
  bucket_purpose = "upload"
  lambda_arn     = module.lambda.lambda_arn  # From another module
  
  # Tags from local values
  tags = local.common_tags
}

# Processed bucket without Lambda trigger
module "processed_bucket" {
  source = "./module/s3"  # Same module, different config
  
  bucket_name    = "image-processing-processed-${random_string.bucket_suffix.result}"
  bucket_purpose = "processed"
  lambda_arn     = null  # No Lambda trigger needed
  
  tags = local.common_tags
}

# Using outputs from modules
resource "aws_lambda_permission" "s3_invoke" {
  source_arn = module.upload_bucket.bucket_arn  # Using module output
  # ...
}
```

## 🔄 Module Communication Flow

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Root Module   │───▶│  S3 Module      │───▶│  AWS S3 Bucket  │
│   (main.tf)     │    │  (module/s3/)   │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │ Inputs:               │ Creates:              │ Returns:
         │ • bucket_name         │ • S3 bucket           │ • bucket_arn
         │ • bucket_purpose      │ • Versioning          │ • bucket_name
         │ • lambda_arn          │ • Encryption          │ • bucket_id
         │ • tags                │ • Notifications       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Lambda Module  │◀───│  Uses S3 ARN    │◀───│  Module Output  │
│  (module/lambda)│    │  for permissions │    │  bucket_arn     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🎨 Benefits of Custom Modules

### 1. **🔄 Reusability**
```hcl
# Create multiple S3 buckets with same configuration
module "upload_bucket" {
  source = "./module/s3"
  bucket_name = "upload-bucket"
}

module "backup_bucket" {
  source = "./module/s3"
  bucket_name = "backup-bucket"
}

module "logs_bucket" {
  source = "./module/s3"
  bucket_name = "logs-bucket"
}
```

### 2. **🧹 Organization**
- **Before**: 500+ lines in one file
- **After**: 50 lines in root + organized modules

### 3. **🛡️ Encapsulation**
```hcl
# Module hides complexity
module "database" {
  source = "./module/rds"
  
  # Simple interface
  db_name = "myapp"
  db_size = "small"
}

# Module handles internally:
# - RDS instance
# - Subnet groups
# - Security groups
# - Parameter groups
# - Backup configuration
# - Monitoring setup
```

### 4. **🧪 Testing**
```bash
# Test individual modules
cd module/s3
terraform init
terraform plan

# Test different configurations
terraform plan -var="bucket_name=test-bucket"
```

### 5. **👥 Team Collaboration**
```
Team Structure:
├── DevOps Engineer    → Creates modules
├── Backend Developer  → Uses database module
├── Frontend Developer → Uses S3 module
└── Security Engineer  → Reviews module security
```

## 📏 Module Rules and Limitations

### ✅ **Rules to Follow**

#### 1. **File Structure (MANDATORY)**
```
module/my-module/
├── main.tf       # REQUIRED - Resources
├── variables.tf  # REQUIRED - Inputs
└── outputs.tf    # REQUIRED - Outputs
```

#### 2. **Variable Validation**
```hcl
variable "environment" {
  type = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

#### 3. **Proper Naming**
```hcl
# ✅ Good naming
resource "aws_s3_bucket" "this" {  # Use "this" for main resource
  bucket = var.bucket_name
}

# ❌ Bad naming
resource "aws_s3_bucket" "my_super_awesome_bucket_resource" {
  bucket = var.bucket_name
}
```

#### 4. **Output Everything Important**
```hcl
# ✅ Good outputs
output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket
}
```

### ⚠️ **Limitations**

#### 1. **No State Sharing**
```hcl
# ❌ This won't work - modules can't share state
module "app1" {
  source = "./module/app"
}

module "app2" {
  source = "./module/app"
  # Can't directly access app1's resources
}
```

#### 2. **No Circular Dependencies**
```hcl
# ❌ This creates circular dependency
module "a" {
  source = "./module/a"
  b_output = module.b.some_value  # A depends on B
}

module "b" {
  source = "./module/b"
  a_output = module.a.some_value  # B depends on A - ERROR!
}
```

#### 3. **Limited Dynamic Behavior**
```hcl
# ❌ Can't use dynamic module sources
module "dynamic" {
  source = var.module_path  # ERROR - source must be static
}

# ✅ Use conditional resources instead
resource "aws_instance" "web" {
  count = var.create_instance ? 1 : 0
  # ...
}
```

## 🎯 Best Practices from Our Project

### 1. **Logical Grouping**
```
✅ Our modules group related resources:
├── s3/         → S3 bucket + versioning + encryption + notifications
├── lambda/     → Lambda function + IAM role + CloudWatch logs
├── cloudwatch/ → Alarms + dashboards + metric filters
└── sns/        → SNS topics + subscriptions + policies
```

### 2. **Clear Interfaces**
```hcl
# ✅ Clear, documented variables
variable "notification_email" {
  description = "Email address for SNS notifications"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.notification_email))
    error_message = "Please provide a valid email address."
  }
}
```

### 3. **Flexible Configuration**
```hcl
# ✅ Support different use cases
module "s3_bucket" {
  source = "./module/s3"
  
  bucket_name     = "my-bucket"
  lambda_arn      = var.enable_processing ? module.lambda.arn : null
  lifecycle_rules = var.environment == "prod" ? local.prod_lifecycle : local.dev_lifecycle
}
```

## 🚀 How to Create Your Own Module

### Step 1: **Plan Your Module**
```
What will it do?
├── Create RDS database
├── Set up security groups
├── Configure backups
└── Enable monitoring
```

### Step 2: **Create Directory Structure**
```bash
mkdir -p module/rds
cd module/rds
touch main.tf variables.tf outputs.tf
```

### Step 3: **Define Variables**
```hcl
# module/rds/variables.tf
variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_size" {
  description = "Size of the database (small, medium, large)"
  type        = string
  default     = "small"
  
  validation {
    condition     = contains(["small", "medium", "large"], var.db_size)
    error_message = "Database size must be small, medium, or large."
  }
}
```

### Step 4: **Create Resources**
```hcl
# module/rds/main.tf
locals {
  instance_classes = {
    small  = "db.t3.micro"
    medium = "db.t3.small"
    large  = "db.t3.medium"
  }
}

resource "aws_db_instance" "this" {
  identifier     = var.db_name
  instance_class = local.instance_classes[var.db_size]
  engine         = "mysql"
  # ... more configuration
}
```

### Step 5: **Define Outputs**
```hcl
# module/rds/outputs.tf
output "db_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.this.port
}
```

### Step 6: **Use in Root Module**
```hcl
# main.tf
module "database" {
  source = "./module/rds"
  
  db_name = "myapp-db"
  db_size = "medium"
}

# Use outputs
output "database_url" {
  value = "mysql://${module.database.db_endpoint}:${module.database.db_port}"
}
```

## 🎓 Key Takeaways

### ✅ **DO**
- Group related resources together
- Use clear, descriptive variable names
- Add validation to variables
- Document everything with descriptions
- Output important resource attributes
- Use consistent naming conventions
- Test modules independently

### ❌ **DON'T**
- Put unrelated resources in same module
- Create circular dependencies
- Use dynamic module sources
- Hardcode values that should be variables
- Create modules that are too complex
- Forget to version your modules
- Skip documentation

## 🏆 **Why Our Project Uses Modules**

1. **🔧 Maintainability**: Each service (S3, Lambda, CloudWatch) is separate
2. **🔄 Reusability**: S3 module used for both upload and processed buckets
3. **🧪 Testability**: Can test each module independently
4. **👥 Team Work**: Different team members can work on different modules
5. **📈 Scalability**: Easy to add new features by creating new modules
6. **🛡️ Security**: Consistent security practices across all modules

**Result**: Clean, organized, professional Terraform code that's perfect for your resume! 🎯