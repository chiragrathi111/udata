# 🏗️ 3-Tier Architecture (Starter Template)

## 📋 Overview

Starter template for 3-tier architecture. Currently contains basic setup with random password generation for database credentials.

## 🎯 What is 3-Tier Architecture?

```
Presentation Tier → Application Tier → Data Tier
(Web Servers)      (App Servers)      (Database)
```

## 📁 Current Setup

- Random password generation for RDS
- AWS caller identity data source
- Basic provider configuration

## 🚀 To Complete This Project

Add these components:

1. **VPC & Networking**
   - VPC with public/private subnets
   - Internet Gateway, NAT Gateway
   - Route tables

2. **Presentation Tier**
   - ALB (Application Load Balancer)
   - Auto Scaling Group for web servers
   - Security groups

3. **Application Tier**
   - Auto Scaling Group for app servers
   - Private subnets
   - Security groups

4. **Data Tier**
   - RDS database (MySQL/PostgreSQL)
   - Private subnets
   - Security groups

## 💡 Reference

See complete implementations:
- `/3tier-web-app` - Full 3-tier with modules
- `/aws-3tier-terraform` - Complete 3-tier setup
- `/2tier` - Simpler 2-tier example

---

**Starter template for 3-tier architecture** 🏗️
