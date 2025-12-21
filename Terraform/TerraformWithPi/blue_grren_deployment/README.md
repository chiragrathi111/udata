# Blue-Green Deployment with Terraform

This project implements a **Blue-Green Deployment** strategy using AWS EC2 instances, Auto Scaling Groups, and Application Load Balancer. Blue-Green deployment allows zero-downtime deployments by maintaining two identical production environments.

## 🎯 What is Blue-Green Deployment?

Blue-Green deployment is a technique that reduces downtime and risk by running two identical production environments called **Blue** and **Green**:

- **Blue Environment**: Currently live environment serving all production traffic
- **Green Environment**: Identical environment with new version, ready for deployment
- **Switch**: Traffic is instantly switched from Blue to Green when new version is ready
- **Rollback**: If issues occur, traffic can be instantly switched back to Blue

## 🏗️ Architecture Overview

```
Internet → ALB → Blue Environment (Active)
            ↓
            → Green Environment (Standby)
```

### Components:
- **VPC**: Isolated network with public/private subnets across 2 AZs
- **Application Load Balancer**: Routes traffic between Blue/Green environments
- **Auto Scaling Groups**: Manages EC2 instances for each environment
- **Security Groups**: Controls network access
- **NAT Gateways**: Provides internet access for private instances

## 📁 File Structure

```
blue_grren_deployment/
├── main.tf              # VPC, subnets, networking
├── security_groups.tf   # Security group rules
├── load_balancer.tf     # ALB, target groups, listeners
├── auto_scaling.tf      # ASG, launch templates, scaling policies
├── user_data.sh         # Instance configuration script
├── variable.tf          # Input variables
├── output.tf            # Output values
├── provide.tf           # Terraform and AWS provider config
├── terraform.tfvars     # Variable values
├── .gitignore          # Git ignore rules
└── README.md           # This file
```

## 🔧 File Explanations

### `main.tf` - Network Infrastructure
- **VPC**: Creates isolated network (10.0.0.0/16)
- **Public Subnets**: For load balancer (internet-facing)
- **Private Subnets**: For EC2 instances (secure)
- **Internet Gateway**: Provides internet access
- **NAT Gateways**: Allow private instances to reach internet
- **Route Tables**: Control traffic routing

### `security_groups.tf` - Network Security
- **ALB Security Group**: Allows HTTP/HTTPS from internet
- **EC2 Security Group**: Allows traffic only from ALB + SSH access
- **Principle of Least Privilege**: Minimal required access

### `load_balancer.tf` - Traffic Management
- **Application Load Balancer**: Distributes incoming traffic
- **Blue Target Group**: Routes traffic to blue environment
- **Green Target Group**: Routes traffic to green environment
- **Listener**: Determines which environment receives traffic
- **Health Checks**: Monitors instance health

### `auto_scaling.tf` - Instance Management
- **Launch Templates**: Define instance configuration for each environment
- **Auto Scaling Groups**: Manage instance lifecycle
- **Scaling Policies**: Handle traffic-based scaling
- **Instance Refresh**: Enable rolling updates

### `user_data.sh` - Instance Configuration
- **Web Server Setup**: Installs and configures Apache
- **Environment Display**: Shows which environment is active
- **Health Endpoint**: Provides health check endpoint
- **Version Information**: Displays current application version

## 🚀 Deployment Process

### 1. Initial Setup
```bash
# Clone and navigate to directory
cd blue_grren_deployment/

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy infrastructure
terraform apply
```

### 2. Access Application
After deployment, Terraform outputs the load balancer URL:
```
load_balancer_url = "http://blue-green-alb-123456789.us-east-1.elb.amazonaws.com"
```

### 3. Blue-Green Deployment Workflow

#### Step 1: Deploy New Version to Inactive Environment
```bash
# Update green environment version
# Edit terraform.tfvars:
green_version = "v2.0.0"

# Apply changes (only affects green environment)
terraform apply
```

#### Step 2: Test New Version
```bash
# Test inactive environment using test URL
curl http://your-alb-dns/test/

# Verify new version is working correctly
```

#### Step 3: Switch Traffic (Zero Downtime)
```bash
# Edit terraform.tfvars to switch active environment:
active_environment = "green"

# Apply changes (traffic switches instantly)
terraform apply
```

#### Step 4: Rollback if Needed
```bash
# If issues occur, switch back immediately:
active_environment = "blue"
terraform apply
```

## 🎛️ Configuration Variables

### Network Settings
- `vpc_cidr`: VPC IP range (default: 10.0.0.0/16)
- `availability_zones`: AZs for deployment (default: us-east-1a, us-east-1b)

### Instance Settings
- `instance_type`: EC2 instance type (default: t3.micro - free tier)
- `key_name`: SSH key pair name (optional)

### Auto Scaling Settings
- `min_size`: Minimum instances (default: 1)
- `max_size`: Maximum instances (default: 4)
- `desired_capacity`: Target instances (default: 2)

### Blue-Green Settings
- `active_environment`: Current active environment (blue/green)
- `blue_version`: Version in blue environment
- `green_version`: Version in green environment

## 🔍 Monitoring and Testing

### Health Checks
- **Endpoint**: `/health`
- **Frequency**: Every 30 seconds
- **Healthy Threshold**: 2 consecutive successes
- **Unhealthy Threshold**: 2 consecutive failures

### Testing Endpoints
- **Main Application**: `http://your-alb-dns/`
- **Test Inactive**: `http://your-alb-dns/test/`
- **Health Check**: `http://your-alb-dns/health`
- **API Info**: `http://your-alb-dns/api/info`

### Environment Identification
Each environment displays:
- Environment name (Blue/Green)
- Version number
- Instance ID
- Availability Zone
- Timestamp

## 💡 Best Practices Implemented

### 1. **Zero Downtime Deployment**
- Traffic switches instantly at load balancer level
- No instance restarts required
- Rollback capability within seconds

### 2. **High Availability**
- Multi-AZ deployment
- Auto Scaling for fault tolerance
- Health checks ensure only healthy instances serve traffic

### 3. **Security**
- Private subnets for application instances
- Security groups with minimal required access
- NAT Gateways for secure internet access

### 4. **Cost Optimization**
- Inactive environment scales to 0 instances
- Free tier eligible instance types
- Efficient resource utilization

### 5. **Monitoring**
- Health check endpoints
- Instance metadata display
- Version tracking

## 🚨 Common Issues and Solutions

### Issue 1: Health Check Failures
**Symptoms**: Instances marked unhealthy
**Solutions**:
- Check security group allows ALB access on port 80
- Verify `/health` endpoint returns HTTP 200
- Check instance logs: `sudo tail -f /var/log/httpd/error_log`

### Issue 2: Cannot Access Application
**Symptoms**: Timeout or connection refused
**Solutions**:
- Verify ALB security group allows port 80/443 from internet
- Check if instances are in private subnets with NAT Gateway access
- Confirm target group has healthy instances

### Issue 3: Deployment Stuck
**Symptoms**: Terraform apply hangs
**Solutions**:
- Check AWS service limits
- Verify IAM permissions
- Review CloudFormation events in AWS console

## 🔄 Deployment Scenarios

### Scenario 1: Regular Update
1. Deploy new version to inactive environment
2. Test thoroughly using test URL
3. Switch traffic when confident
4. Monitor for issues
5. Keep old version ready for rollback

### Scenario 2: Emergency Rollback
1. Immediately switch `active_environment` variable
2. Run `terraform apply`
3. Traffic switches back in ~30 seconds
4. Investigate issues in now-inactive environment

### Scenario 3: Database Migration
1. Deploy new version with backward-compatible changes
2. Run database migration
3. Switch traffic to new environment
4. Remove backward compatibility in next release

## 🧹 Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning**: This will delete all infrastructure and cannot be undone.

## 📊 Cost Estimation

### Free Tier Usage:
- **EC2 Instances**: t3.micro (750 hours/month free)
- **Load Balancer**: ~$16/month (not free tier)
- **NAT Gateway**: ~$32/month (not free tier)
- **Data Transfer**: First 1GB free

### Cost Optimization Tips:
- Use single NAT Gateway for development
- Scale inactive environment to 0 instances
- Use spot instances for non-production

## 🔗 Additional Resources

- [AWS Blue/Green Deployment Guide](https://docs.aws.amazon.com/whitepapers/latest/blue-green-deployments/welcome.html)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Auto Scaling Best Practices](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-benefits.html)

## 🤝 Contributing

1. Test changes in development environment
2. Update documentation for any configuration changes
3. Follow Terraform best practices
4. Ensure security groups follow least privilege principle