# Node Selector Complete Guide 🎯
## Simple Pod Placement

---

## What is Node Selector? 🤔

**Node Selector** = Simple way to schedule pods on specific nodes

**Think of it like:**
- Hotel = Kubernetes cluster
- Rooms = Nodes
- Guest preference = Node Selector
- "I want smoking room" = disktype=ssd

---

## Why Use Node Selector? 💡

### Use Cases:
1. **Hardware Requirements** - GPU nodes for ML
2. **Storage Type** - SSD vs HDD
3. **Geographic Location** - US vs EU nodes
4. **Cost Optimization** - Spot instances for dev

---

## How It Works 🔄

```
1. Label nodes
   ↓
2. Add nodeSelector to pod
   ↓
3. Kubernetes schedules pod on matching node
```

---

## Example 📝

### Step 1: Label Node

```bash
# Add label to node
kubectl label nodes node1 disktype=ssd

# View node labels
kubectl get nodes --show-labels

# Remove label
kubectl label nodes node1 disktype-
```

### Step 2: Use in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  nodeSelector:
    disktype: ssd        # Only schedule on nodes with this label
  containers:
  - name: app
    image: nginx
```

---

## Real-World Examples 🌍

### Example 1: GPU Workload

```bash
# Label GPU node
kubectl label nodes gpu-node1 gpu=true

# Pod requiring GPU
apiVersion: v1
kind: Pod
metadata:
  name: ml-training
spec:
  nodeSelector:
    gpu: "true"
  containers:
  - name: ml-app
    image: tensorflow:latest
    resources:
      limits:
        nvidia.com/gpu: 1
```

### Example 2: Zone-Based

```bash
# Label nodes by zone
kubectl label nodes node1 zone=us-east-1a
kubectl label nodes node2 zone=us-east-1b

# Pod in specific zone
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  nodeSelector:
    zone: us-east-1a
  containers:
  - name: app
    image: nginx
```

### Example 3: Environment-Based

```bash
# Label nodes by environment
kubectl label nodes node1 environment=production
kubectl label nodes node2 environment=development

# Production pod
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prod-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: prod-app
  template:
    metadata:
      labels:
        app: prod-app
    spec:
      nodeSelector:
        environment: production
      containers:
      - name: app
        image: myapp:v2.0
```

---

## Multiple Labels 🏷️

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  nodeSelector:
    disktype: ssd
    zone: us-east-1a
    environment: production
  containers:
  - name: app
    image: nginx
```

**Result:** Pod only schedules on nodes with ALL three labels

---

## Commands 🔧

```bash
# Label node
kubectl label nodes node1 key=value

# View labels
kubectl get nodes --show-labels

# View specific label
kubectl get nodes -L disktype

# Remove label
kubectl label nodes node1 key-

# Update label
kubectl label nodes node1 key=newvalue --overwrite
```

---

## Limitations ❌

1. **Simple matching only** - Can't use OR logic
2. **No preferences** - Either matches or fails
3. **No weights** - Can't prefer certain nodes

**For advanced scheduling, use Node Affinity!**

---

## Best Practices 📚

### 1. Use Meaningful Labels
```bash
# ✅ Good
disktype=ssd
zone=us-east-1a
instance-type=m5.large

# ❌ Bad
type=1
label=abc
```

### 2. Document Labels
```bash
# Keep track of labels used
# disktype: ssd, hdd
# zone: us-east-1a, us-east-1b
# environment: prod, dev
```

### 3. Use with Taints
```bash
# Taint node for dedicated workloads
kubectl taint nodes node1 dedicated=gpu:NoSchedule

# Then use nodeSelector + toleration
```

---

## Troubleshooting 🔍

### Issue 1: Pod pending

```bash
# Check pod status
kubectl describe pod webapp

# Events: 0/3 nodes available: node(s) didn't match node selector

# Solution: Check node labels
kubectl get nodes --show-labels

# Add missing label
kubectl label nodes node1 disktype=ssd
```

---

## Key Takeaways 🎯

1. **Node Selector** = Simple pod placement
2. **Label nodes** = First step
3. **Add nodeSelector** = In pod spec
4. **All labels must match** = AND logic
5. **Use Node Affinity** = For complex rules

**Node Selector = Simple Scheduling! 🎯**
