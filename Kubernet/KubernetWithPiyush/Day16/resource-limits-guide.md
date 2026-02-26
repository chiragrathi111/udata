# Resource Limits & Metrics Complete Guide 📊
## CPU & Memory Management

---

## What are Resource Limits? 🤔

**Resources** = CPU and Memory for containers

**Two Types:**
- **Requests** = Minimum guaranteed
- **Limits** = Maximum allowed

---

## Why Use Them? 💡

### Without Limits:
```
Pod1: Uses 90% CPU (hogs resources)
Pod2: Gets 5% CPU (starves)
Pod3: Gets 5% CPU (starves)
❌ Unfair!
```

### With Limits:
```
Pod1: Max 33% CPU (limited)
Pod2: Gets 33% CPU (fair share)
Pod3: Gets 33% CPU (fair share)
✅ Fair!
```

---

## Resource Units 📏

### CPU:
- 1 CPU = 1000m (millicores)
- 500m = 0.5 CPU = half a core
- 100m = 0.1 CPU = 10% of a core

### Memory:
- 128Mi = 128 Mebibytes
- 1Gi = 1 Gibibyte
- 1G = 1 Gigabyte

---

## Example 📝

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: 250m          # Guaranteed 0.25 CPU
        memory: 256Mi      # Guaranteed 256MB
      limits:
        cpu: 500m          # Max 0.5 CPU
        memory: 512Mi      # Max 512MB
```

**What happens:**
- Kubernetes reserves 250m CPU and 256Mi memory
- Pod can use up to 500m CPU and 512Mi memory
- If exceeds memory limit → OOMKilled
- If exceeds CPU limit → Throttled

---

## QoS Classes 🎯

### 1. Guaranteed (Best)
```yaml
requests = limits
```
**Priority:** Highest (last to be evicted)

### 2. Burstable (Medium)
```yaml
requests < limits
```
**Priority:** Medium

### 3. BestEffort (Lowest)
```yaml
No requests or limits
```
**Priority:** Lowest (first to be evicted)

---

## Metrics Server 📊

```bash
# Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# View node metrics
kubectl top nodes

# View pod metrics
kubectl top pods

# View pod metrics in namespace
kubectl top pods -n production

# Sort by CPU
kubectl top pods --sort-by=cpu

# Sort by memory
kubectl top pods --sort-by=memory
```

---

## Real-World Example: Production App 🏭

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: production-app
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
      containers:
      - name: app
        image: myapp:v2.0
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
          limits:
            cpu: 1000m
            memory: 1Gi
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
```

---

## Best Practices 📚

### 1. Always Set Requests
```yaml
# ✅ Good
resources:
  requests:
    cpu: 100m
    memory: 128Mi

# ❌ Bad
resources: {}
```

### 2. Set Limits to Prevent Hogging
```yaml
limits:
  cpu: 500m
  memory: 512Mi
```

### 3. Monitor Usage
```bash
kubectl top pods
kubectl top nodes
```

### 4. Use LimitRange for Defaults
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
spec:
  limits:
  - default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    type: Container
```

---

## Troubleshooting 🔍

### Issue 1: OOMKilled
```bash
# Pod killed due to memory
kubectl describe pod <pod-name>
# Reason: OOMKilled

# Solution: Increase memory limit
resources:
  limits:
    memory: 1Gi
```

### Issue 2: CPU Throttling
```bash
# Pod slow, CPU throttled
kubectl top pod <pod-name>

# Solution: Increase CPU limit
resources:
  limits:
    cpu: 1000m
```

### Issue 3: Pending Pods
```bash
# Not enough resources
kubectl describe pod <pod-name>
# Events: Insufficient cpu

# Solution: Add nodes or reduce requests
```

---

## Key Takeaways 🎯

1. **Requests** = Guaranteed minimum
2. **Limits** = Maximum allowed
3. **Always set** = Prevent resource hogging
4. **Monitor** = Use metrics-server
5. **QoS** = Guaranteed > Burstable > BestEffort

**Resource Limits = Fair Resource Sharing! 📊**
