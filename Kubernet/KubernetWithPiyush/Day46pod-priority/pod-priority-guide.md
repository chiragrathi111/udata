# Pod Priority & Preemption Guide ⭐
## Resource Prioritization

---

## What is Pod Priority? 🤔

**Pod Priority** = Importance level for pods

**Think of it like:**
- VIP vs regular customers
- Emergency vs routine
- Production vs development

---

## Why Use Priority? 💡

### Without Priority:
```
Node full → New pod pending → All pods equal ❌
Production pod can't schedule
```

### With Priority:
```
Node full → High priority pod → Evicts low priority → Schedules ✅
Production pod gets resources
```

---

## Priority Classes 🎯

### Creating PriorityClass

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "High priority for production workloads"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: medium-priority
value: 100000
globalDefault: false
description: "Medium priority for staging workloads"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 1000
globalDefault: true
description: "Low priority for development workloads"
```

---

## Using Priority in Pods 📝

```yaml
# High priority pod (production)
apiVersion: v1
kind: Pod
metadata:
  name: prod-app
spec:
  priorityClassName: high-priority
  containers:
  - name: app
    image: myapp:latest
---
# Low priority pod (development)
apiVersion: v1
kind: Pod
metadata:
  name: dev-app
spec:
  priorityClassName: low-priority
  containers:
  - name: app
    image: myapp:dev
```

---

## Preemption 🔄

**What happens:**
```
1. Node has 8GB RAM, all used
2. High priority pod needs 2GB
3. Kubernetes evicts low priority pods
4. High priority pod schedules
```

---

## Real-World Example 🌍

```yaml
# Priority Classes
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: production-critical
value: 1000000
preemptionPolicy: PreemptLowerPriority
description: "Critical production workloads"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: production-normal
value: 500000
description: "Normal production workloads"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: development
value: 1000
globalDefault: true
description: "Development workloads"
---
# Production Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: payment
  template:
    metadata:
      labels:
        app: payment
    spec:
      priorityClassName: production-critical
      containers:
      - name: payment
        image: payment:v2.0
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
---
# Development Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
spec:
  replicas: 5
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      priorityClassName: development
      containers:
      - name: test
        image: test:latest
```

**Scenario:**
```
Node full with dev pods
Payment service needs resources
Dev pods evicted
Payment service schedules ✅
```

---

## Commands 🔧

```bash
# List priority classes
kubectl get priorityclasses
kubectl get pc

# Describe priority class
kubectl describe pc high-priority

# Get pod priority
kubectl get pod my-pod -o yaml | grep priorityClassName
```

---

## Best Practices 📚

### 1. Define Clear Priorities
```
Critical: 1000000 (databases, payment)
High: 500000 (production apps)
Medium: 100000 (staging)
Low: 1000 (development)
```

### 2. Set Global Default
```yaml
globalDefault: true  # For low priority
```

### 3. Use with Resource Quotas
```yaml
# Prevent abuse of high priority
```

### 4. Monitor Preemptions
```bash
kubectl get events | grep Preempted
```

---

## Key Takeaways 🎯

1. **Priority** = Importance level
2. **Preemption** = Evict low priority
3. **Use for** = Production vs dev
4. **Critical workloads** = High priority
5. **Monitor** = Preemption events

**Pod Priority = Resource Fairness! ⭐**
