# 🎯 2-Tier Architecture - Practical Deployment Guide

## 📋 Real-World Scenario: WordPress Blog Platform

### **Business Requirement**
You're hired to deploy a WordPress blog for a client. They need:
- **Web Server**: Running WordPress (PHP application)
- **Database**: MySQL for storing posts, users, comments
- **Security**: Database should NOT be accessible from internet
- **Scalability**: Ability to add more web servers later

### **Solution: 2-Tier Architecture**

```
┌──────────────────────────────────────────────────────────┐
│                    INTERNET                               │
└────────────────────┬─────────────────────────────────────┘
                     │
            ┌────────▼────────┐
            │ Internet Gateway │
            └────────┬────────┘
                     │
┌────────────────────┼─────────────────────────────────────┐
│ VPC: 10.0.0.0/16   │                                     │
│                    │                                     │
│  ┌─────────────────▼──────────────────────────────┐     │
│  │ PUBLIC SUBNET (10.0.1.0/24)                    │     │
│  │ ┌────────────────────────────────────────┐     │     │
│  │ │ EC2: WordPress Web Server              │     │     │
│  │ │ • Public IP: 54.123.45.67             │     │     │
│  │ │ • Ports: 80 (HTTP), 443 (HTTPS)      │     │     │
│  │ │ • Connects to DB on port 3306         │     │     │
│  │ └────────────────────────────────────────┘     │     │
│  └─────────────────┬──────────────────────────────┘     │
│                    │                                     │
│  ┌─────────────────▼──────────────────────────────┐     │
│  │ PRIVATE SUBNET (10.0.2.0/24)                  │     │
│  │ ┌────────────────────────────────────────┐     │     │
│  │ │ RDS: MySQL Database                    │     │     │
│  │ │ • NO Public IP (Secure!)              │     │     │
│  │ │ • Port: 3306 (only from web server)   │     │     │
│  │ │ • Database: wordpress_db               │     │     │
│  │ └────────────────────────────────────────┘     │     │
│  └────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────┘
```

## 🔄 Step-by-Step Deployment

### **Step 1: Understand the Flow**

```
User Browser
    ↓
Internet (HTTP/HTTPS)
    ↓
Internet Gateway
    ↓
Public Subnet → EC2 Web Server (WordPress)
    ↓
Private Subnet → RDS Database (MySQL)
```

**Key Point**: Database is NEVER exposed to internet!

### **Step 2: Configure Variables**

```hcl
# terraform.tfvars
region = "us-east-1"
project_name = "wordpress-blog"
environment = "production"

# Network Configuration
vpc_cidr = "10.0.0.0/16"
public_subnet = "10.0.1.0/24"
private_subnet = ["10.0.2.0/24", "10.0.3.0/24"]  # 2 AZs for RDS

# Web Server Configuration
ec2_instance_type = "t3.small"  # WordPress needs more than t2.micro
port = [80, 443, 22]  # HTTP, HTTPS, SSH

# Database Configuration
db_name = "wordpress_db"
db_username = "wp_admin"
db_instance_class = "db.t3.micro"
db_allocated_storage = 20
db_engine_version = "8.0"
db_port = 3306
```

### **Step 3: Deploy Infrastructure**

```bash
# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Deploy (takes 5-10 minutes)
terraform apply

# Get important information
terraform output
```

### **Step 4: Access Your WordPress**

```bash
# Get web server public IP
terraform output ec2_public_ip

# Access in browser
http://<ec2_public_ip>

# Complete WordPress installation
# Database Host: <rds_endpoint from terraform output>
# Database Name: wordpress_db
# Username: wp_admin
# Password: <from SSM parameter store>
```

## 🎓 Module Communication Flow

### **How Modules Talk to Each Other**

```hcl
# main.tf

# 1. VPC Module creates network
module \"vpc\" {
  source = \"./module/vpc\"
  vpc_cidr = \"10.0.0.0/16\"
}
# OUTPUT: vpc_id, public_subnet_id, private_subnet_ids

# 2. Security Groups Module uses VPC ID
module \"sg\" {
  source = \"./module/sg\"
  vpc_id = module.vpc.vpc_id  # ← Uses VPC output
}
# OUTPUT: web_sg_id, db_sg_id

# 3. RDS Module uses private subnets and DB security group
module \"rds\" {
  source = \"./module/rds\"
  private_subnet_ids = module.vpc.private_subnet_ids  # ← Uses VPC output
  db_security_group_id = module.sg.db_sg_id  # ← Uses SG output
  db_password = module.ssm.db_password  # ← Uses SSM output
}
# OUTPUT: db_endpoint

# 4. EC2 Module uses public subnet, web SG, and DB endpoint
module \"ec2\" {
  source = \"./module/ec2\"
  public_subnet_id = module.vpc.public_subnet_id  # ← Uses VPC output
  web_security_group_id = module.sg.web_sg_id  # ← Uses SG output
  db_host = module.rds.db_endpoint  # ← Uses RDS output
  db_password = module.ssm.db_password  # ← Uses SSM output
}
```

**Key Concept**: Modules are like LEGO blocks - each has inputs and outputs that connect to other modules!

## 🔍 Troubleshooting Common Issues

### **Issue 1: Can't Access Web Server**

```bash
# Check if EC2 is running
aws ec2 describe-instances --filters \"Name=tag:Name,Values=*web*\" \
  --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]'

# Check security group allows your IP
aws ec2 describe-security-groups --group-ids <web-sg-id> \
  --query 'SecurityGroups[].IpPermissions[]'

# Solution: Update security group to allow your IP
```

### **Issue 2: Web Server Can't Connect to Database**

```bash
# Check if RDS is available
aws rds describe-db-instances --db-instance-identifier <db-id> \
  --query 'DBInstances[].[DBInstanceStatus,Endpoint.Address]'

# Check security group allows web server
aws ec2 describe-security-groups --group-ids <db-sg-id>

# Solution: Verify DB security group allows traffic from web SG
```

### **Issue 3: Database Password Not Working**

```bash
# Get password from SSM
aws ssm get-parameter --name \"/dev/db_password\" --with-decryption \
  --query 'Parameter.Value' --output text

# Solution: Use this password in WordPress installation
```

## 💡 Real-World Improvements

### **Add Load Balancer (Upgrade to 3-Tier)**

```hcl
# Add ALB module
module \"alb\" {
  source = \"./module/alb\"
  
  vpc_id = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnet_ids
  target_instances = module.ec2.instance_ids
}

# Now users access: ALB DNS → Web Servers → Database
```

### **Add Auto Scaling**

```hcl
# Replace single EC2 with Auto Scaling Group
module \"asg\" {
  source = \"./module/asg\"
  
  min_size = 2  # Minimum 2 web servers
  max_size = 5  # Maximum 5 web servers
  desired_capacity = 2
  
  # Scale based on CPU
  scale_up_threshold = 70
  scale_down_threshold = 30
}
```

### **Add CloudWatch Monitoring**

```hcl
# Add monitoring module
module \"monitoring\" {
  source = \"./module/cloudwatch\"
  
  ec2_instance_ids = module.ec2.instance_ids
  rds_instance_id = module.rds.db_instance_id
  
  # Alert on high CPU
  cpu_alarm_threshold = 80
  
  # Alert on low disk space
  disk_alarm_threshold = 90
}
```

## 📊 Cost Breakdown (Monthly)

| Resource | Type | Cost (USD) |
|----------|------|------------|
| EC2 (Web) | t3.small | ~$15 |
| RDS (DB) | db.t3.micro | ~$15 |
| EBS Storage | 20GB | ~$2 |
| Data Transfer | 10GB | ~$1 |
| **Total** | | **~$33/month** |

**Cost Optimization Tips:**
- Use t3.micro for development ($7/month)
- Use Reserved Instances for production (30-50% savings)
- Enable auto-scaling to scale down during low traffic

## 🎯 Interview Questions & Answers

**Q: Why separate web and database into different subnets?**
A: Security! Database in private subnet has no internet access, reducing attack surface. Only web servers can access it.

**Q: What happens if web server fails?**
A: With auto-scaling, a new instance automatically launches. With load balancer, traffic routes to healthy instances.

**Q: How do modules communicate?**
A: Through outputs and inputs. One module's output becomes another module's input variable.

**Q: Why use modules instead of single file?**
A: Reusability, maintainability, testing, and team collaboration. Same module can deploy dev, staging, and prod.

## 🚀 Next Steps

1. **Deploy this 2-tier architecture**
2. **Add monitoring with CloudWatch**
3. **Implement auto-scaling**
4. **Add load balancer (upgrade to 3-tier)**
5. **Set up CI/CD pipeline**

## 📚 Related Projects

- **3-tier**: Add load balancer layer
- **vpc_custom_module**: Deep dive into VPC module
- **blue_green_deployment**: Zero-downtime deployments

---

**Perfect for Resume**: Shows understanding of multi-tier architecture, AWS networking, security best practices, and infrastructure automation!