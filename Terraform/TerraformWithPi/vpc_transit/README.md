# Multi-Region Transit Gateway with Terraform

This project implements **AWS Transit Gateway** across multiple regions to connect VPCs and enable seamless communication between them. Transit Gateway acts as a network hub that simplifies connectivity between VPCs, on-premises networks, and other AWS services.

## 🎯 What is AWS Transit Gateway?

AWS Transit Gateway is a service that enables customers to connect their VPCs and on-premises networks to a single gateway. It acts as a hub that controls how traffic is routed among all the connected networks.

### Key Benefits:
- **Simplified Network Architecture**: Single point of connection for multiple VPCs
- **Scalable**: Supports thousands of VPCs and on-premises connections
- **Cross-Region Connectivity**: Connect VPCs across different AWS regions
- **Centralized Management**: Single place to manage routing policies
- **Cost Effective**: Reduces the number of connections needed

## 🏗️ Architecture Overview

```
Region: us-east-1          Region: us-west-2          Region: eu-west-1
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│      VPC1       │       │      VPC2       │       │      VPC3       │
│  12.0.0.0/16    │       │  13.0.0.0/16    │       │  14.0.0.0/16    │
└─────────┬───────┘       └─────────┬───────┘       └─────────┬───────┘
          │                         │                         │
          │                         │                         │
    ┌─────▼─────┐             ┌─────▼─────┐             ┌─────▼─────┐
    │    TGW    │◄────────────┤    TGW    │◄────────────┤    TGW    │
    │ us-east-1 │   Peering   │ us-west-2 │   Peering   │ eu-west-1 │
    └───────────┘             └───────────┘             └───────────┘
```

### Components:
- **3 VPCs**: Each in different regions (us-east-1, us-west-2, eu-west-1)
- **3 Transit Gateways**: One per region for local VPC attachment
- **TGW Peering**: Cross-region connections between Transit Gateways
- **Route Tables**: Automatic route propagation for seamless connectivity

## 📁 File Structure

```
vpc_transit/
├── main.tf              # VPC infrastructure (3 VPCs across regions)
├── tgw.tf              # Transit Gateway setup and peering
├── tgw_routes.tf       # Routing configuration between VPCs
├── security_groups.tf   # Security group rules (if exists)
├── instance.tf         # EC2 instances for testing (if exists)
├── data.tf             # Data sources (AZs, AMIs)
├── variable.tf         # Input variables
├── output.tf           # Output values and instructions
├── provider.tf         # Terraform and AWS provider config
├── terraform.tfvars    # Variable values
└── README.md           # This file
```

## 🔧 File Explanations

### `main.tf` - VPC Infrastructure
- **3 VPCs**: Creates VPCs in different regions with non-overlapping CIDR blocks
- **Subnets**: Public subnets in each VPC for instance deployment
- **Internet Gateways**: Provide internet access for each VPC
- **Route Tables**: Basic routing for internet access

### `tgw.tf` - Transit Gateway Setup
- **Regional TGWs**: Creates one Transit Gateway per region
- **VPC Attachments**: Connects each VPC to its regional TGW
- **TGW Peering**: Establishes cross-region connectivity
- **Peering Accepters**: Accepts peering connections in target regions

### `tgw_routes.tf` - Routing Configuration
- **VPC Routes**: Adds routes to VPC route tables for cross-VPC communication
- **Destination CIDRs**: Routes traffic to other VPC CIDR blocks via TGW
- **Dependencies**: Ensures proper order of resource creation

### `provider.tf` - Multi-Region Providers
- **Provider Aliases**: Separate providers for each region
- **Default Provider**: Primary provider for us-east-1

## 🚀 Deployment Process

### 1. Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform installed (version ~> 1.14.0)
- Sufficient AWS service limits for TGW in all regions

### 2. Deploy Infrastructure
```bash
# Navigate to directory
cd vpc_transit/

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy infrastructure
terraform apply
```

### 3. Verify Deployment
After deployment, check the outputs:
```bash
terraform output
```

## 🔍 Understanding Transit Gateway Concepts

### 1. **Transit Gateway (TGW)**
- Regional service that acts as a network hub
- Supports up to 5,000 VPC attachments per TGW
- Automatically handles routing between attached networks

### 2. **VPC Attachments**
- Connects VPC to Transit Gateway
- Requires subnet in each AZ for high availability
- Enables communication between VPC and TGW

### 3. **TGW Peering**
- Connects Transit Gateways across regions
- Enables cross-region VPC communication
- Requires acceptance in the peer region

### 4. **Route Tables**
- Control traffic flow through TGW
- Default route table automatically propagates routes
- Custom route tables allow granular control

### 5. **ASN (Autonomous System Number)**
- Each TGW needs unique ASN for BGP routing
- Private ASN range: 64512-65534
- Used for route advertisement and loop prevention

## 🎛️ Configuration Variables

### Network Settings
- `region`: Map of regions for each VPC
- `cidr`: CIDR blocks for each VPC (must not overlap)
- `vpc`: VPC names for identification
- `subnet`: Subnet names for each VPC

### Infrastructure Settings
- `igw`: Internet Gateway names
- `rt`: Route table names
- `instance_type`: EC2 instance type for testing
- `port`: Security group ports (SSH, HTTP, HTTPS)

## 🔄 Traffic Flow Examples

### Example 1: VPC1 to VPC2 Communication
1. **Source**: Instance in VPC1 (12.0.1.10)
2. **Destination**: Instance in VPC2 (13.0.1.10)
3. **Path**: VPC1 → TGW-us-east-1 → TGW-Peering → TGW-us-west-2 → VPC2

### Example 2: VPC1 to VPC3 Communication
1. **Source**: Instance in VPC1 (12.0.1.10)
2. **Destination**: Instance in VPC3 (14.0.1.10)
3. **Path**: VPC1 → TGW-us-east-1 → TGW-Peering → TGW-eu-west-1 → VPC3

## 🧪 Testing Connectivity

### 1. Deploy Test Instances
```bash
# Add EC2 instances to each VPC for testing
# Ensure security groups allow ICMP and SSH
```

### 2. Test Cross-VPC Ping
```bash
# From VPC1 instance, ping VPC2
ping 13.0.1.10

# From VPC1 instance, ping VPC3
ping 14.0.1.10

# From VPC2 instance, ping VPC3
ping 14.0.1.10
```

### 3. Verify Route Tables
```bash
# Check VPC route tables in AWS Console
# Verify TGW routes are present
# Confirm TGW peering status is "available"
```

## 🚨 Common Issues and Solutions

### Issue 1: TGW Peering Connection Stuck in "Pending"
**Cause**: Peering accepter not configured in target region
**Solution**: Ensure peering accepter resources are deployed in target regions

### Issue 2: Cannot Ping Between VPCs
**Causes & Solutions**:
- **Security Groups**: Allow ICMP traffic between VPC CIDR blocks
- **Route Tables**: Verify routes to TGW are present
- **TGW State**: Ensure TGW and attachments are in "available" state

### Issue 3: High Data Transfer Costs
**Cause**: Cross-region traffic through TGW peering
**Solutions**:
- Monitor traffic patterns
- Consider VPC peering for high-volume connections
- Optimize application architecture to reduce cross-region calls

## 💰 Cost Considerations

### Transit Gateway Costs
- **TGW Hourly Charge**: ~$36/month per TGW (24/7)
- **Data Processing**: $0.02 per GB processed
- **TGW Peering**: Additional data transfer charges

### Cost Optimization Tips
1. **Consolidate VPCs**: Reduce number of TGWs by using fewer regions
2. **Monitor Usage**: Use AWS Cost Explorer to track TGW costs
3. **Alternative Solutions**: Consider VPC peering for simple point-to-point connections
4. **Right-sizing**: Only deploy TGW where hub-and-spoke model is needed

### Monthly Cost Estimate
- **3 TGWs**: ~$108/month
- **Data Processing**: Variable based on traffic
- **Total**: $150-300/month depending on usage

## 🔒 Security Best Practices

### 1. **Network Segmentation**
- Use security groups to control traffic between VPCs
- Implement least privilege access
- Consider using TGW route tables for additional control

### 2. **Monitoring**
- Enable VPC Flow Logs
- Monitor TGW metrics in CloudWatch
- Set up alerts for unusual traffic patterns

### 3. **Access Control**
- Use IAM policies to control TGW management
- Implement resource-based policies where needed
- Regular audit of TGW configurations

## 🔄 Deployment Scenarios

### Scenario 1: Hub-and-Spoke Architecture
- Central VPC (hub) with shared services
- Multiple spoke VPCs for different applications
- All traffic routes through hub for centralized control

### Scenario 2: Mesh Connectivity
- All VPCs can communicate with each other
- Suitable for microservices architectures
- Current implementation follows this pattern

### Scenario 3: Hybrid Connectivity
- Connect on-premises networks via VPN/Direct Connect
- Extend corporate network to AWS
- Centralized connectivity management

## 🧹 Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning**: This will delete all TGWs, VPCs, and associated resources. Ensure you have backups of any important data.

## 📊 Monitoring and Troubleshooting

### Key Metrics to Monitor
- **TGW Attachment State**: Should be "available"
- **Peering Connection State**: Should be "available"
- **Data Processing**: Monitor for cost optimization
- **Packet Drop Count**: Indicates routing issues

### Troubleshooting Commands
```bash
# Check TGW status
aws ec2 describe-transit-gateways

# Check attachments
aws ec2 describe-transit-gateway-attachments

# Check peering connections
aws ec2 describe-transit-gateway-peering-attachments

# Check route tables
aws ec2 describe-transit-gateway-route-tables
```

## 🤝 Best Practices Summary

1. **Plan CIDR Blocks**: Ensure no overlap between VPCs
2. **Use Consistent Naming**: Follow naming conventions for resources
3. **Monitor Costs**: Regular review of TGW usage and costs
4. **Security First**: Implement proper security group rules
5. **Document Architecture**: Maintain network diagrams and documentation
6. **Test Connectivity**: Regular testing of cross-VPC communication
7. **Backup Configurations**: Version control all Terraform code

## 🔗 Additional Resources

- [AWS Transit Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/tgw/)
- [TGW Peering Guide](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-peering.html)
- [TGW Best Practices](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-best-design-practices.html)
- [Terraform AWS Provider - TGW Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway)