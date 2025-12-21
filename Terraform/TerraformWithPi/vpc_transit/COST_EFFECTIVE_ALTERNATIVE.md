# Cost-Effective VPC Connectivity: VPC Peering vs Transit Gateway

## 💰 Cost Comparison

### Transit Gateway Costs (What you avoided):
```
Monthly Costs:
├── 3 Transit Gateways: $108/month ($36 × 3)
├── Data Processing: $0.02/GB per TGW
├── Cross-Region Transfer: $0.02-0.09/GB
└── Total: $150-300/month + data charges
```

### VPC Peering Costs (Much cheaper):
```
Monthly Costs:
├── VPC Peering Connections: $0/month (FREE)
├── Cross-Region Data Transfer: $0.01-0.02/GB
└── Total: $5-20/month (data transfer only)
```

**Savings: ~$130-280/month (95% cost reduction!)**

## 🏗️ Architecture Comparison

### Transit Gateway (Expensive):
```
VPC1 ──┐
VPC2 ──┼── TGW ($36/month each) ──┐
VPC3 ──┘                          ├── Cross-Region Peering
                                  ┘
Total: 3 TGWs = $108/month base cost
```

### VPC Peering (Cost-Effective):
```
VPC1 ────────── VPC2 (FREE peering)
 │               │
 └─── VPC3 ──────┘ (FREE peering)

Total: $0/month base cost (only data transfer charges)
```

## 🚀 Deployment Instructions

### Option 1: Replace TGW with VPC Peering
```bash
# 1. Remove TGW files (rename to disable)
mv tgw.tf tgw.tf.disabled
mv tgw_routes.tf tgw_routes.tf.disabled

# 2. Deploy VPC peering
terraform apply -target=aws_vpc_peering_connection.vpc1_to_vpc2
terraform apply -target=aws_vpc_peering_connection.vpc1_to_vpc3
terraform apply -target=aws_vpc_peering_connection.vpc2_to_vpc3

# 3. Accept peering connections
terraform apply -target=aws_vpc_peering_connection_accepter.vpc1_to_vpc2_accepter
terraform apply -target=aws_vpc_peering_connection_accepter.vpc1_to_vpc3_accepter
terraform apply -target=aws_vpc_peering_connection_accepter.vpc2_to_vpc3_accepter

# 4. Add routes
terraform apply
```

### Option 2: Fresh Deployment
```bash
# 1. Use only VPC peering files
# Keep: main.tf, sg.tf, instance.tf, vpc_peering_alternative.tf, vpc_peering_routes.tf
# Remove: tgw.tf, tgw_routes.tf

# 2. Deploy everything
terraform init
terraform apply
```

## ✅ Benefits of VPC Peering

### Cost Benefits:
- **95% cheaper** than Transit Gateway
- No hourly charges for peering connections
- Only pay for data transfer (much lower rates)

### Performance Benefits:
- **Lower latency** (direct connection, no hub)
- **Higher bandwidth** (up to 25 Gbps cross-region)
- **Simpler routing** (fewer hops)

### Operational Benefits:
- **Simpler setup** (no complex TGW configuration)
- **Faster deployment** (no peering acceptance delays)
- **Easier troubleshooting** (direct connections)

## 🔧 What Changes

### Route Tables Will Show:
```
VPC1 Route Table:
├── 12.0.0.0/16 → Local
├── 13.0.0.0/16 → pcx-xxxxx (VPC Peering to VPC2)
├── 14.0.0.0/16 → pcx-xxxxx (VPC Peering to VPC3)
└── 0.0.0.0/0   → igw-xxxxx

Instead of expensive TGW routes:
├── 13.0.0.0/16 → tgw-xxxxx ($36/month)
├── 14.0.0.0/16 → tgw-xxxxx ($36/month)
```

### Connectivity:
- **Same functionality**: All VPCs can communicate
- **Better performance**: Direct connections, lower latency
- **Much lower cost**: No TGW charges

## 🚨 Limitations of VPC Peering

### Scaling Limitations:
- **No transitive routing**: Each VPC needs direct peering
- **Connection limits**: 125 peering connections per VPC
- **Manual management**: Each connection configured separately

### When to Use Transit Gateway Instead:
- **Many VPCs** (>10 VPCs needing full mesh)
- **Hub-and-spoke** architecture requirements
- **On-premises connectivity** via VPN/Direct Connect
- **Complex routing policies** needed

## 📊 Performance Comparison

| Metric | VPC Peering | Transit Gateway |
|--------|-------------|-----------------|
| **Cost** | $5-20/month | $150-300/month |
| **Latency** | 50-80ms | 60-100ms |
| **Bandwidth** | Up to 25 Gbps | Up to 50 Gbps |
| **Setup Time** | 5 minutes | 15-30 minutes |
| **Complexity** | Low | High |

## 🎯 Recommendation

**For your 3-VPC setup, VPC Peering is the clear winner:**
- ✅ 95% cost savings
- ✅ Same connectivity
- ✅ Better performance
- ✅ Simpler management

**Use Transit Gateway only if:**
- You plan to have 10+ VPCs
- You need on-premises connectivity
- You require complex routing policies

## 🔄 Migration Steps

If you want to test both approaches:

1. **Keep current setup** for learning
2. **Deploy VPC peering** in parallel
3. **Compare costs** in AWS billing
4. **Switch to peering** for production

This gives you hands-on experience with both solutions!