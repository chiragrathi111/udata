# JSONPath in Kubernetes Guide 🔍
## Query Kubernetes Objects

---

## What is JSONPath? 🤔

**JSONPath** = Query language for JSON data

**Use in Kubernetes:**
- Extract specific fields
- Filter data
- Scripting and automation

---

## Basic Syntax 📝

```bash
# Get pod names
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# Get pod IPs
kubectl get pods -o jsonpath='{.items[*].status.podIP}'

# Get node names
kubectl get nodes -o jsonpath='{.items[*].metadata.name}'
```

---

## Common Patterns 🎯

### 1. Get All Pod Names
```bash
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
```

### 2. Get Pod IPs
```bash
kubectl get pods -o jsonpath='{.items[*].status.podIP}'
```

### 3. Get Container Images
```bash
kubectl get pods -o jsonpath='{.items[*].spec.containers[*].image}'
```

### 4. Get Node IPs
```bash
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'
```

### 5. Get Service ClusterIPs
```bash
kubectl get svc -o jsonpath='{.items[*].spec.clusterIP}'
```

---

## Filtering 🔎

```bash
# Get pods in Running state
kubectl get pods -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}'

# Get nodes with specific label
kubectl get nodes -o jsonpath='{.items[?(@.metadata.labels.disktype=="ssd")].metadata.name}'
```

---

## Formatting Output 📊

```bash
# With newlines
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'

# With tabs
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.podIP}{"\n"}{end}'

# Custom format
kubectl get pods -o jsonpath='{range .items[*]}{"Pod: "}{.metadata.name}{" IP: "}{.status.podIP}{"\n"}{end}'
```

---

## Real-World Examples 🌍

### Example 1: Get All Container Images
```bash
kubectl get pods -A -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | sort -u
```

### Example 2: Get Pods with Resource Limits
```bash
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources.limits.memory}{"\n"}{end}'
```

### Example 3: Get Service Endpoints
```bash
kubectl get endpoints -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.subsets[*].addresses[*].ip}{"\n"}{end}'
```

---

## Useful Commands 🔧

```bash
# Get pod names and namespaces
kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\n"}{end}'

# Get node capacity
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.capacity.cpu}{"\t"}{.status.capacity.memory}{"\n"}{end}'

# Get PVC sizes
kubectl get pvc -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.resources.requests.storage}{"\n"}{end}'
```

---

## Key Takeaways 🎯

1. **JSONPath** = Query JSON data
2. **Use with -o jsonpath** = kubectl flag
3. **Extract fields** = Specific data
4. **Filter** = Conditional queries
5. **Automate** = Scripts and CI/CD

**JSONPath = Powerful Queries! 🔍**
