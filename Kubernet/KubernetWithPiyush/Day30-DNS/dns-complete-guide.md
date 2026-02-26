# Kubernetes DNS Complete Guide 🌐
## Service Discovery

---

## What is Kubernetes DNS? 🤔

**Kubernetes DNS** = Internal DNS server for service discovery

**Think of it like:**
- Phone book for services
- Instead of IP addresses, use names
- "Call backend-api" instead of "Call 10.96.100.50"

---

## Why Use DNS? 💡

### Without DNS:
```
Frontend needs to connect to backend
Backend IP: 10.96.100.50
Backend restarts → New IP: 10.96.100.75
Frontend breaks ❌
```

### With DNS:
```
Frontend connects to: backend-api
Backend restarts → DNS updated automatically
Frontend still works ✅
```

---

## DNS Format 📋

```
<service-name>.<namespace>.svc.cluster.local
```

**Examples:**
```
backend-api.production.svc.cluster.local
mysql.database.svc.cluster.local
redis.cache.svc.cluster.local
```

---

## DNS Resolution 🔍

### Same Namespace:
```bash
# Service: backend-api
# Namespace: production

# From pod in same namespace
curl http://backend-api
curl http://backend-api:8080
```

### Different Namespace:
```bash
# Service: backend-api
# Namespace: production

# From pod in different namespace
curl http://backend-api.production
curl http://backend-api.production.svc.cluster.local
```

---

## CoreDNS 🎯

**CoreDNS** = DNS server in Kubernetes

```bash
# Check CoreDNS pods
kubectl get pods -n kube-system | grep coredns

# Check CoreDNS config
kubectl get configmap coredns -n kube-system -o yaml

# CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns
```

---

## DNS for Services 🌐

```yaml
# Service
apiVersion: v1
kind: Service
metadata:
  name: backend-api
  namespace: production
spec:
  selector:
    app: backend
  ports:
  - port: 8080
```

**DNS Names:**
```
backend-api                                    (same namespace)
backend-api.production                         (cross namespace)
backend-api.production.svc                     (full)
backend-api.production.svc.cluster.local       (FQDN)
```

---

## DNS for Pods 🎪

**Format:**
```
<pod-ip-with-dashes>.<namespace>.pod.cluster.local
```

**Example:**
```
Pod IP: 10.244.1.5
DNS: 10-244-1-5.default.pod.cluster.local
```

---

## Testing DNS 🧪

```bash
# Run test pod
kubectl run test --image=busybox -it --rm -- sh

# Inside pod, test DNS
nslookup kubernetes.default
nslookup backend-api
nslookup backend-api.production

# Check /etc/resolv.conf
cat /etc/resolv.conf
# nameserver 10.96.0.10
# search default.svc.cluster.local svc.cluster.local cluster.local
```

---

## Custom DNS 🛠️

### Pod DNS Config:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  dnsPolicy: "None"
  dnsConfig:
    nameservers:
    - 8.8.8.8
    - 8.8.4.4
    searches:
    - production.svc.cluster.local
    - svc.cluster.local
    options:
    - name: ndots
      value: "2"
  containers:
  - name: app
    image: nginx
```

---

## DNS Policies 📋

### 1. ClusterFirst (Default)
```yaml
dnsPolicy: ClusterFirst
# Use cluster DNS, fallback to node DNS
```

### 2. Default
```yaml
dnsPolicy: Default
# Use node's DNS
```

### 3. None
```yaml
dnsPolicy: None
# Use custom DNS config
```

### 4. ClusterFirstWithHostNet
```yaml
dnsPolicy: ClusterFirstWithHostNet
# For pods using hostNetwork
```

---

## Real-World Example 🌍

```yaml
# Microservices with DNS
---
# Frontend Service
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: production
spec:
  selector:
    app: frontend
  ports:
  - port: 80
---
# Backend Service
apiVersion: v1
kind: Service
metadata:
  name: backend-api
  namespace: production
spec:
  selector:
    app: backend
  ports:
  - port: 8080
---
# Database Service
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: production
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
---
# Frontend Pod
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: production
spec:
  containers:
  - name: app
    image: frontend:latest
    env:
    - name: BACKEND_URL
      value: "http://backend-api:8080"    # DNS name!
---
# Backend Pod
apiVersion: v1
kind: Pod
metadata:
  name: backend
  namespace: production
spec:
  containers:
  - name: app
    image: backend:latest
    env:
    - name: DATABASE_URL
      value: "mysql://mysql:3306/mydb"    # DNS name!
```

---

## Troubleshooting 🔍

### Issue 1: DNS not resolving

```bash
# Check CoreDNS
kubectl get pods -n kube-system | grep coredns

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# Test DNS from pod
kubectl run test --image=busybox -it --rm -- nslookup kubernetes.default
```

### Issue 2: Slow DNS resolution

```bash
# Check CoreDNS resources
kubectl top pods -n kube-system | grep coredns

# Scale CoreDNS
kubectl scale deployment coredns -n kube-system --replicas=3
```

---

## Best Practices 📚

### 1. Use Service Names
```yaml
# ✅ Good
DATABASE_URL: mysql:3306

# ❌ Bad
DATABASE_URL: 10.96.100.50:3306
```

### 2. Use Short Names (Same Namespace)
```yaml
# ✅ Good (same namespace)
BACKEND_URL: backend-api:8080

# ❌ Bad (unnecessary)
BACKEND_URL: backend-api.production.svc.cluster.local:8080
```

### 3. Use Full Names (Cross Namespace)
```yaml
# ✅ Good (different namespace)
BACKEND_URL: backend-api.production:8080
```

---

## Key Takeaways 🎯

1. **DNS** = Service discovery
2. **Format** = service.namespace.svc.cluster.local
3. **CoreDNS** = DNS server
4. **Use names** = Not IP addresses
5. **Automatic** = DNS updated automatically

**Kubernetes DNS = Easy Service Discovery! 🌐**
