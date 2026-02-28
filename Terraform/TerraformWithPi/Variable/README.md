# 📝 Terraform Variables - Complete Mastery Guide

## 📋 What is This Project?

This project is a **complete reference guide** for Terraform variables, covering:
- Variable precedence (priority order)
- Variable types (string, list, set, map)
- count vs for_each
- depends_on relationships
- Real-world examples

## 🎯 Variable Precedence (Priority Order)

Terraform loads variables in this order (lowest to highest priority):

```
1. Default Value (in variable block)
   ↓
2. Environment Variables (TF_VAR_*)
   ↓
3. terraform.tfvars
   ↓
4. terraform.tfvars.json
   ↓
5. *.auto.tfvars (alphabetical order)
   ↓
6. *.auto.tfvars.json (alphabetical order)
   ↓
7. -var or -var-file (command line)
   ↑
HIGHEST PRIORITY
```

### 🔍 Real-World Example

```hcl
# 1. Default value in variable.tf
variable "environment" {
  default = "dev"
}

# 2. Environment variable (overrides default)
# export TF_VAR_environment="staging"

# 3. terraform.tfvars (overrides env var)
# environment = "prod"

# 4. Command line (overrides everything)
# terraform apply -var="environment=test"

# Result: environment = "test" (command line wins!)
```

## 📊 Variable Types

### 1. **String** - Single Value
```hcl
variable "region" {
  type    = string
  default = "us-east-1"
}

# Usage
provider "aws" {
  region = var.region
}
```

### 2. **List** - Ordered Collection
```hcl
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Usage with count
resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  availability_zone = var.availability_zones[count.index]
}
```

### 3. **Set** - Unique Collection (No Duplicates)
```hcl
variable "allowed_ports" {
  type    = set(number)
  default = [80, 443, 22]  # Duplicates automatically removed
}

# Usage with for_each
resource "aws_security_group_rule" "ingress" {
  for_each    = var.allowed_ports
  from_port   = each.value
  to_port     = each.value
  protocol    = "tcp"
}
```

### 4. **Map** - Key-Value Pairs
```hcl
variable "instance_types" {
  type = map(string)
  default = {
    dev  = "t2.micro"
    prod = "t3.large"
  }
}

# Usage
resource "aws_instance" "web" {
  instance_type = var.instance_types[var.environment]
}
```

### 5. **Object** - Complex Structure
```hcl
variable "database_config" {
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
    allocated_storage = number
  })
  
  default = {
    engine         = "postgres"
    engine_version = "15.3"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Usage
resource "aws_db_instance" "main" {
  engine         = var.database_config.engine
  engine_version = var.database_config.engine_version
  instance_class = var.database_config.instance_class
}
```

## 🔄 count vs for_each

### **count** - Use with Lists (Ordered)

```hcl
variable "s3_bucket_names" {
  type    = list(string)
  default = ["bucket-a", "bucket-b", "bucket-c"]
}

resource "aws_s3_bucket" "example" {
  count  = length(var.s3_bucket_names)
  bucket = var.s3_bucket_names[count.index]
  
  tags = {
    Name  = "Bucket ${count.index + 1}"
    Index = count.index
  }
}

# Access: aws_s3_bucket.example[0], aws_s3_bucket.example[1]
```

**⚠️ count Problem**: If you remove "bucket-b", "bucket-c" becomes index 1, causing recreation!

```
Before: [bucket-a, bucket-b, bucket-c]
         index 0   index 1   index 2

After:  [bucket-a, bucket-c]
         index 0   index 1   ← bucket-c moved! Will be recreated!
```

### **for_each** - Use with Sets/Maps (Unordered)

```hcl
variable "s3_bucket_set" {
  type    = set(string)
  default = ["bucket-a", "bucket-b", "bucket-c"]
}

resource "aws_s3_bucket" "example" {
  for_each = var.s3_bucket_set
  bucket   = each.value
  
  tags = {
    Name = "Bucket ${each.key}"
  }
}

# Access: aws_s3_bucket.example["bucket-a"]
```

**✅ for_each Advantage**: Removing "bucket-b" doesn't affect others!

```
Before: {bucket-a, bucket-b, bucket-c}

After:  {bucket-a, bucket-c}  ← Only bucket-b deleted, others unchanged!
```

### **for_each with Map** - Best for Complex Resources

```hcl
variable "environments" {
  type = map(object({
    instance_type = string
    disk_size     = number
  }))
  
  default = {
    dev = {
      instance_type = "t2.micro"
      disk_size     = 20
    }
    prod = {
      instance_type = "t3.large"
      disk_size     = 100
    }
  }
}

resource "aws_instance" "app" {
  for_each      = var.environments
  instance_type = each.value.instance_type
  
  root_block_device {
    volume_size = each.value.disk_size
  }
  
  tags = {
    Name        = "app-${each.key}"
    Environment = each.key
  }
}

# Access: aws_instance.app["dev"], aws_instance.app["prod"]
```

## 🔗 depends_on - Resource Dependencies

### Explicit Dependencies

```hcl
# Scenario: Bucket B needs Bucket A to exist first

resource "aws_s3_bucket" "logs" {
  bucket = "my-app-logs-bucket"
}

resource "aws_s3_bucket" "app" {
  bucket = "my-app-bucket"
  
  # Wait for logs bucket to be created first
  depends_on = [aws_s3_bucket.logs]
}

# Terraform will create logs bucket first, then app bucket
```

### Real-World Example: Database → Application

```hcl
# 1. Create database first
resource "aws_db_instance" "main" {
  identifier = "myapp-db"
  engine     = "postgres"
  # ... other config
}

# 2. Create application instances (need DB to be ready)
resource "aws_instance" "app" {
  count = 3
  ami   = "ami-12345678"
  
  user_data = templatefile("app-init.sh", {
    db_endpoint = aws_db_instance.main.endpoint
  })
  
  # Explicit dependency
  depends_on = [aws_db_instance.main]
}

# 3. Create load balancer (needs app instances)
resource "aws_lb" "main" {
  name = "app-lb"
  
  depends_on = [aws_instance.app]
}
```

## 🎯 Real-World Scenarios

### Scenario 1: Multi-Environment Deployment

```hcl
variable "environments" {
  type = map(object({
    instance_count = number
    instance_type  = string
    db_size        = number
  }))
  
  default = {
    dev = {
      instance_count = 1
      instance_type  = "t2.micro"
      db_size        = 20
    }
    staging = {
      instance_count = 2
      instance_type  = "t3.small"
      db_size        = 50
    }
    prod = {
      instance_count = 5
      instance_type  = "t3.large"
      db_size        = 200
    }
  }
}

# Deploy all environments
resource "aws_instance" "app" {
  for_each = var.environments
  
  count         = each.value.instance_count
  instance_type = each.value.instance_type
  
  tags = {
    Environment = each.key
    Name        = "${each.key}-app-${count.index + 1}"
  }
}
```

### Scenario 2: Regional Deployment

```hcl
variable "regions" {
  type = map(object({
    vpc_cidr = string
    azs      = list(string)
  }))
  
  default = {
    us-east-1 = {
      vpc_cidr = "10.0.0.0/16"
      azs      = ["us-east-1a", "us-east-1b"]
    }
    eu-west-1 = {
      vpc_cidr = "10.1.0.0/16"
      azs      = ["eu-west-1a", "eu-west-1b"]
    }
  }
}

# Create VPC in each region
resource "aws_vpc" "regional" {
  for_each = var.regions
  
  cidr_block = each.value.vpc_cidr
  
  tags = {
    Name   = "${each.key}-vpc"
    Region = each.key
  }
}
```

### Scenario 3: Conditional Resources

```hcl
variable "create_bastion" {
  type    = bool
  default = false
}

variable "environment" {
  type    = string
  default = "dev"
}

# Only create bastion in production
resource "aws_instance" "bastion" {
  count = var.environment == "prod" && var.create_bastion ? 1 : 0
  
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  tags = {
    Name = "bastion-host"
  }
}
```

## 📋 Variable Validation

```hcl
variable "environment" {
  type = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_count" {
  type = number
  
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "email" {
  type = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.email))
    error_message = "Must be a valid email address."
  }
}
```

## 🎓 Best Practices

### ✅ DO

```hcl
# 1. Use descriptive names
variable "database_instance_class" {  # Good
  type = string
}

# 2. Add descriptions
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# 3. Use validation
variable "region" {
  type = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "Must be a valid AWS region."
  }
}

# 4. Use for_each for flexibility
resource "aws_s3_bucket" "example" {
  for_each = var.bucket_names  # Flexible
}
```

### ❌ DON'T

```hcl
# 1. Avoid unclear names
variable "x" {  # Bad
  type = string
}

# 2. Don't hardcode sensitive data
variable "db_password" {
  default = "password123"  # NEVER DO THIS!
}

# 3. Don't use count for named resources
resource "aws_s3_bucket" "example" {
  count = 3  # Bad - hard to reference specific buckets
}
```

## 🎯 Interview Questions

**Q: What's the difference between count and for_each?**
A: count uses numeric indices (0, 1, 2) and is order-dependent. for_each uses keys and is order-independent, making it better for managing resources that might be added/removed.

**Q: How do you pass sensitive variables?**
A: Use environment variables (TF_VAR_*), -var command line, or mark as sensitive in the variable block.

**Q: What is variable precedence?**
A: The order Terraform loads variables: default → env vars → tfvars → auto.tfvars → command line (highest priority).

## 📚 Quick Reference

| Type | Use Case | Example |
|------|----------|---------|
| **string** | Single value | region, name |
| **number** | Numeric value | count, port |
| **bool** | True/false | enable_monitoring |
| **list** | Ordered collection | availability_zones |
| **set** | Unique collection | security_group_ids |
| **map** | Key-value pairs | instance_types |
| **object** | Complex structure | database_config |

---

**Perfect for Resume**: Demonstrates deep understanding of Terraform variables, resource management, and infrastructure patterns!