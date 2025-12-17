# Cross-Region VPC Peering with Terraform

This Terraform configuration creates a cross-region VPC peering connection between two AWS regions with EC2 instances for testing connectivity.

## Architecture

- **Primary VPC**: us-east-1 (10.0.0.0/16)
- **Secondary VPC**: us-west-2 (192.68.0.0/16)
- **VPC Peering**: Cross-region connection between the VPCs
- **EC2 Instances**: One in each VPC for connectivity testing

## Key Fixes Applied

### 1. **Removed Invalid Attributes**
- **Issue**: VPC and data sources had invalid `region` attributes
- **Fix**: Removed `region` from resources (they inherit from provider)
- **Lesson**: Resources get their region from the provider configuration, not from resource attributes

### 2. **Added Provider Aliases**
- **Issue**: Cross-region resources need different providers
- **Fix**: Added `aws.primary` and `aws.secondary` provider aliases
- **Lesson**: Multi-region deployments require provider aliases for each region

### 3. **Fixed Resource Targeting**
- **Issue**: Secondary region resources weren't using correct provider
- **Fix**: Added `provider = aws.secondary` to all secondary region resources
- **Lesson**: Always specify provider alias for resources in non-default regions

### 4. **Corrected VPC Peering Setup**
- **Issue**: Peering accepter and routes missing provider aliases
- **Fix**: Added proper provider configuration for cross-region peering
- **Lesson**: VPC peering accepter must use the provider of the peer region

## Files Structure

### `provide.tf`
- **Primary Provider**: Default provider for us-east-1
- **Secondary Provider**: Alias provider for us-west-2
- **Terraform Version**: Specifies required Terraform and AWS provider versions

### `main.tf`
- **Primary VPC**: VPC, subnet, IGW, route table in us-east-1
- **Secondary VPC**: VPC, subnet, IGW, route table in us-west-2 (with provider aliases)
- **VPC Peering**: Cross-region peering connection and routes

### `data.tf`
- **Availability Zones**: Gets available AZs for each region
- **AMI Data**: Fetches latest Ubuntu AMIs for both regions

### `sg.tf`
- **Security Groups**: Allows SSH, HTTP, HTTPS from internet
- **Cross-VPC Rules**: Allows all traffic between peered VPCs
- **ICMP Rules**: Enables ping between VPCs for testing

### `instance.tf`
- **Primary Instance**: EC2 in us-east-1 VPC
- **Secondary Instance**: EC2 in us-west-2 VPC (with provider alias)

### `variable.tf`
- **Regions**: Map of primary and secondary regions
- **CIDR Blocks**: Non-overlapping IP ranges for each VPC
- **Instance Config**: Instance type and key pair names

## Common Mistakes to Avoid

1. **Don't add `region` attribute to resources** - Use provider configuration
2. **Always use provider aliases for multi-region** - Specify `provider = aws.alias`
3. **Check CIDR overlap** - Ensure VPC CIDR blocks don't overlap
4. **VPC peering accepter needs correct provider** - Use peer region's provider
5. **Cross-region routes need provider aliases** - Routes in secondary region need secondary provider

## Usage

1. **Initialize**: `terraform init`
2. **Plan**: `terraform plan`
3. **Apply**: `terraform apply`
4. **Test**: SSH to instances and ping across VPCs

## Testing Connectivity

```bash
# From primary instance, ping secondary instance private IP
ping <secondary-instance-private-ip>

# From secondary instance, ping primary instance private IP  
ping <primary-instance-private-ip>
```

## Security Notes

- Security groups allow all traffic between VPCs (adjust as needed)
- SSH access is open to 0.0.0.0/0 (restrict to your IP in production)
- Instances have public IPs for management access

## Cleanup

Run `terraform destroy` to remove all resources and avoid charges.