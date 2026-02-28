# 🔗 VPC Peering - Complete Guide with Real-World Scenarios

## 📋 What is VPC Peering?

**VPC Peering** connects two VPCs so they can communicate as if they're in the same network, even across different:
- AWS Regions (Cross-Region Peering)
- AWS Accounts (Cross-Account Peering)
- Same Account, Same Region (Intra-Region Peering)

## 🎯 Real-World Scenario: Multi-Region Application

### **Business Problem**
Your company has:
- **Production App** in US-East (Virginia) - serves US customers
- **Analytics System** in US-West (Oregon) - processes data
- **Requirement**: Analytics needs to access production database

### **❌ Bad Solutions**

**Option 1: Public Internet**
```
Production DB (US-East) → Internet → Analytics (US-West)

Problems:
- Insecure (data exposed to internet)
- Slow (goes through public internet)
- Expensive (data transfer costs)
- Complex (need VPN or encryption)
```

**Option 2: Duplicate Data**
```
Copy database to US-West every hour

Problems:
- Data lag (not real-time)
- Storage costs doubled
- Sync complexity
- Data consistency issues
```

### **✅ Good Solution: VPC Peering**
```
Production VPC (US-East) ←→ Analytics VPC (US-West)
                VPC Peering

Benefits:
- Secure (private AWS network)
- Fast (AWS backbone network)
- Cost-effective (lower data transfer)
- Simple (just route configuration)
```

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS GLOBAL NETWORK                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────┐  ┌──────────────────────────┐ │
│  │  US-EAST-1 (Virginia)    │  │  US-WEST-2 (Oregon)      │ │
│  │                          │  │                          │ │
│  │  ┌────────────────────┐  │  │  ┌────────────────────┐  │ │
│  │  │ VPC-A              │  │  │  │ VPC-B              │  │ │
│  │  │ 10.0.0.0/16        │◄─┼──┼─►│ 192.168.0.0/16     │  │ │
│  │  │                    │  │  │  │                    │  │ │
│  │  │ ┌────────────────┐ │  │  │  │ ┌────────────────┐ │  │ │
│  │  │ │ EC2: Web App   │ │  │  │  │ │ EC2: Analytics │ │  │ │
│  │  │ │ 10.0.1.10      │ │  │  │  │ │ 192.168.1.10   │ │  │ │
│  │  │ └────────────────┘ │  │  │  │ └────────────────┘ │  │ │
│  │  │                    │  │  │  │                    │  │ │
│  │  │ ┌────────────────┐ │  │  │  │ ┌────────────────┐ │  │ │
│  │  │ │ RDS: Database  │ │  │  │  │ │ Redshift: DW   │ │  │ │
│  │  │ │ 10.0.2.20      │ │  │  │  │ │ 192.168.2.20   │ │  │ │
│  │  │ └────────────────┘ │  │  │  │ └────────────────┘ │  │ │
│  │  └────────────────────┘  │  │  └────────────────────┘  │ │
│  └──────────────────────────┘  └──────────────────────────┘ │
│              ▲                            ▲                 │
│              │                            │                 │
│              └────────VPC Peering─────────┘                 │
│                   (Private Connection)                      │
└─────────────────────────────────────────────────────────────┘
```

## 🔑 Key Concepts

### **1. Non-Overlapping CIDR Blocks**

```hcl
# ✅ GOOD: Different IP ranges
vpc_a_cidr = \"10.0.0.0/16\"      # 10.0.0.0 - 10.0.255.255
vpc_b_cidr = \"192.168.0.0/16\"   # 192.168.0.0 - 192.168.255.255

# ❌ BAD: Overlapping IP ranges
vpc_a_cidr = \"10.0.0.0/16\"      # 10.0.0.0 - 10.0.255.255
vpc_b_cidr = \"10.0.0.0/24\"      # 10.0.0.0 - 10.0.0.255 (OVERLAP!)
```

**Why?** Routers can't distinguish between overlapping IPs!

### **2. Provider Aliases for Multi-Region**

```hcl
# provider.tf

# Primary region (default)
provider \"aws\" {
  region = \"us-east-1\"
}

# Secondary region (alias)
provider \"aws\" {
  alias  = \"secondary\"
  region = \"us-west-2\"
}

# Usage in resources
resource \"aws_vpc\" \"primary\" {
  # Uses default provider (us-east-1)
  cidr_block = \"10.0.0.0/16\"
}

resource \"aws_vpc\" \"secondary\" {
  provider = aws.secondary  # Uses alias (us-west-2)
  cidr_block = \"192.168.0.0/16\"
}
```

### **3. VPC Peering Connection Flow**

```hcl
# Step 1: Create peering request (from primary)
resource \"aws_vpc_peering_connection\" \"peer\" {
  vpc_id      = aws_vpc.primary.id      # Requester VPC
  peer_vpc_id = aws_vpc.secondary.id    # Accepter VPC
  peer_region = \"us-west-2\"             # Cross-region
  auto_accept = false                   # Manual accept needed
}

# Step 2: Accept peering (in secondary region)
resource \"aws_vpc_peering_connection_accepter\" \"peer\" {
  provider = aws.secondary  # Must use secondary provider!
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept = true
}

# Step 3: Add routes (both directions)
resource \"aws_route\" \"primary_to_secondary\" {
  route_table_id            = aws_route_table.primary.id
  destination_cidr_block    = \"192.168.0.0/16\"  # Secondary VPC
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource \"aws_route\" \"secondary_to_primary\" {
  provider = aws.secondary  # Must use secondary provider!
  route_table_id            = aws_route_table.secondary.id
  destination_cidr_block    = \"10.0.0.0/16\"     # Primary VPC
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
```

## 🎯 Real-World Use Cases

### **Use Case 1: Disaster Recovery**

```
Production VPC (US-East) ←→ DR VPC (US-West)

Setup:
- Primary database in US-East
- Standby database in US-West
- Continuous replication via VPC peering
- Failover in case of disaster
```

### **Use Case 2: Shared Services**

```
App VPC-A ──┐
            ├──→ Shared Services VPC (Active Directory, DNS)
App VPC-B ──┘

Setup:
- Multiple application VPCs
- One shared services VPC
- All apps peer with shared services
- Centralized management
```

### **Use Case 3: Development/Testing**

```
Production VPC ←→ Dev VPC

Setup:
- Production data in prod VPC
- Developers access via dev VPC
- Secure access without exposing prod
- Cost-effective testing
```

### **Use Case 4: Multi-Account Architecture**

```
Account A (Production) ←→ Account B (Analytics)

Setup:
- Production in separate AWS account
- Analytics in different account
- Cross-account VPC peering
- Billing separation
```

## 🔧 Step-by-Step Implementation

### **Step 1: Plan Your CIDR Blocks**

```hcl
# terraform.tfvars
cidr = {
  primary   = \"10.0.0.0/16\"      # US-East VPC
  secondary = \"192.168.0.0/16\"   # US-West VPC
}

# Verify no overlap
# 10.0.0.0/16     = 10.0.0.0 - 10.0.255.255
# 192.168.0.0/16  = 192.168.0.0 - 192.168.255.255
# ✅ No overlap!
```

### **Step 2: Create VPCs in Both Regions**

```hcl
# Primary VPC (US-East)
resource \"aws_vpc\" \"primary\" {
  cidr_block = var.cidr[\"primary\"]
  enable_dns_hostnames = true  # Required for peering
  enable_dns_support   = true  # Required for peering
}

# Secondary VPC (US-West)
resource \"aws_vpc\" \"secondary\" {
  provider = aws.secondary  # Important!
  cidr_block = var.cidr[\"secondary\"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

### **Step 3: Create Peering Connection**

```hcl
# Request peering
resource \"aws_vpc_peering_connection\" \"peer\" {
  vpc_id      = aws_vpc.primary.id
  peer_vpc_id = aws_vpc.secondary.id
  peer_region = \"us-west-2\"
  auto_accept = false
}

# Accept peering
resource \"aws_vpc_peering_connection_accepter\" \"peer\" {
  provider = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept = true
}
```

### **Step 4: Update Route Tables**

```hcl
# Primary → Secondary route
resource \"aws_route\" \"primary_to_secondary\" {
  route_table_id            = aws_route_table.primary.id
  destination_cidr_block    = var.cidr[\"secondary\"]
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  
  depends_on = [aws_vpc_peering_connection_accepter.peer]
}

# Secondary → Primary route
resource \"aws_route\" \"secondary_to_primary\" {
  provider = aws.secondary
  route_table_id            = aws_route_table.secondary.id
  destination_cidr_block    = var.cidr[\"primary\"]
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  
  depends_on = [aws_vpc_peering_connection_accepter.peer]
}
```

### **Step 5: Update Security Groups**

```hcl
# Allow traffic from peered VPC
resource \"aws_security_group_rule\" \"allow_from_peer\" {
  type              = \"ingress\"
  from_port         = 0
  to_port           = 65535
  protocol          = \"-1\"
  cidr_blocks       = [var.cidr[\"secondary\"]]
  security_group_id = aws_security_group.primary.id
}
```

## 🐛 Common Issues & Solutions

### **Issue 1: Can't Ping Across VPCs**

```bash
# Check 1: Verify peering is active
aws ec2 describe-vpc-peering-connections \
  --filters \"Name=status-code,Values=active\"

# Check 2: Verify routes exist
aws ec2 describe-route-tables \
  --route-table-ids rtb-12345678

# Check 3: Verify security groups
aws ec2 describe-security-groups \
  --group-ids sg-12345678

# Solution: Ensure routes and security groups allow traffic
```

### **Issue 2: DNS Resolution Not Working**

```hcl
# Enable DNS resolution for peering
resource \"aws_vpc_peering_connection_options\" \"primary\" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  
  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource \"aws_vpc_peering_connection_options\" \"secondary\" {
  provider = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}
```

### **Issue 3: Overlapping CIDR Blocks**

```
Error: Cannot create peering - CIDR blocks overlap

Solution: Change one VPC's CIDR block
- VPC A: 10.0.0.0/16
- VPC B: 10.1.0.0/16 (was 10.0.0.0/24)
```

## 💰 Cost Comparison

### **VPC Peering vs Alternatives**

| Solution | Data Transfer Cost | Setup Complexity | Performance |
|----------|-------------------|------------------|-------------|
| **VPC Peering** | $0.01/GB | Low | High |
| **VPN** | $0.05/GB + $0.05/hour | Medium | Medium |
| **Transit Gateway** | $0.02/GB + $0.05/hour | High | High |
| **Public Internet** | $0.09/GB | Low | Low |

**Example: 100GB/month transfer**
- VPC Peering: $1/month
- VPN: $5 + $36 = $41/month
- Transit Gateway: $2 + $36 = $38/month
- Public Internet: $9/month (but insecure!)

## 🎓 Best Practices

### ✅ DO

```hcl
# 1. Use non-overlapping CIDR blocks
vpc_a = \"10.0.0.0/16\"
vpc_b = \"192.168.0.0/16\"

# 2. Enable DNS resolution
enable_dns_hostnames = true
enable_dns_support   = true

# 3. Use specific security group rules
cidr_blocks = [var.peer_vpc_cidr]  # Not 0.0.0.0/0

# 4. Add depends_on for routes
depends_on = [aws_vpc_peering_connection_accepter.peer]

# 5. Tag resources properly
tags = {
  Name = \"primary-to-secondary-peering\"
  Environment = \"production\"
}
```

### ❌ DON'T

```hcl
# 1. Don't use overlapping CIDRs
vpc_a = \"10.0.0.0/16\"
vpc_b = \"10.0.1.0/24\"  # Overlaps!

# 2. Don't forget provider aliases
resource \"aws_vpc\" \"secondary\" {
  # Missing: provider = aws.secondary
}

# 3. Don't open security groups to all
cidr_blocks = [\"0.0.0.0/0\"]  # Too permissive!

# 4. Don't forget DNS settings
# Missing: enable_dns_hostnames = true
```

## 🎯 Interview Questions

**Q: What is VPC Peering?**
A: A networking connection between two VPCs that enables routing traffic between them using private IP addresses.

**Q: Can you peer VPCs with overlapping CIDR blocks?**
A: No, CIDR blocks must not overlap for peering to work.

**Q: What's the difference between VPC Peering and Transit Gateway?**
A: VPC Peering is 1-to-1 connection, Transit Gateway is hub-and-spoke (many-to-many).

**Q: How do you enable cross-region VPC peering in Terraform?**
A: Use provider aliases for different regions and specify peer_region in the peering connection.

## 📚 Related Topics

- **Transit Gateway**: For connecting many VPCs
- **PrivateLink**: For service-to-service connections
- **VPN**: For on-premises to AWS connections
- **Direct Connect**: For dedicated network connections

---

**Perfect for Resume**: Demonstrates multi-region architecture, network security, and AWS networking expertise!