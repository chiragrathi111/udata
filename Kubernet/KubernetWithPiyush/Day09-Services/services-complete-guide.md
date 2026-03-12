# Kubernetes Services Complete Guide 🌐
## ClusterIP, NodePort, LoadBalancer Explained

---

## What is a Service? 🤔

**Service** provides a stable network endpoint for accessing pods.

**Problem without Service:**
```
Pods have dynamic IPs:
- Pod1: 10.244.1.5 (restarts → 10.244.1.8)
- Pod2: 10.244.2.3 (restarts → 10.244.2.7)
- How do you connect? IP keeps changing! ❌
```

**Solution with Service:**
```
Service has stable IP:
- Service: 10.96.100.50 (never changes!)
- Routes to healthy pods automatically
- Load balances across pods ✅
```

---

## Types of Services 📊

### 1. ClusterIP (Default)
**What:** Internal-only access
**When:** Pod-to-pod communication
**Example:** Frontend → Backend API

### 2. NodePort
**What:** External access via Node IP
**When:** Development, testing
**Example:** Access app from laptop

### 3. LoadBalancer
**What:** Cloud load balancer
**When:** Production external access
**Example:** Public website

### 4. ExternalName
**What:** DNS alias
**When:** External services
**Example:** AWS RDS database

---

## Service Architecture 🏗️

```
┌─────────────────────────────────────────┐
│            Service                      │
│  ClusterIP: 10.96.100.50               │
│  Port: 80                               │
├─────────────────────────────────────────┤
│                                         │
│  Selector: app=my-app                   │
│             ↓                           │
│  ┌──────────────────────────────────┐  │
│  │  Endpoints (Pod IPs)             │  │
│  │  - 10.244.1.5:8080              │  │
│  │  - 10.244.2.3:8080              │  │
│  │  - 10.244.3.7:8080              │  │
│  └──────────────────────────────────┘  │
│             ↓                           │
│  ┌──────────────────────────────────┐  │
│  │  Pods                            │  │
│  │  - pod1 (app=my-app)            │  │
│  │  - pod2 (app=my-app)            │  │
│  │  - pod3 (app=my-app)            │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

---

## 1. ClusterIP Service 🔒

### What is ClusterIP?
- **Internal-only** access
- Default service type
- Only accessible within cluster
- Stable internal IP

### Your ClusterIP Example:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-clusterip-service
spec:
  type: ClusterIP              # Internal only
  selector:
    app: my-app                # Find pods with this label
  ports:
  - port: 80                   # Service port
    targetPort: 8080           # Pod port
```

### How it Works:

```
1. Service gets ClusterIP: 10.96.100.50
   ↓
2. Finds pods with label app=my-app
   ↓
3. Creates endpoints (pod IPs)
   ↓
4. Other pods connect to 10.96.100.50:80
   ↓
5. Service routes to pod:8080
   ↓
6. Load balances across all pods
```

### When to Use:
- ✅ Backend APIs
- ✅ Databases
- ✅ Internal microservices
- ✅ Pod-to-pod communication

### Real-World Example:

```yaml
# Frontend Service (ClusterIP)
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  type: ClusterIP
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 3000
---
# Backend API Service (ClusterIP)
apiVersion: v1
kind: Service
metadata:
  name: backend-api
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
  - port: 8080
    targetPort: 8080
---
# Database Service (ClusterIP)
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
spec:
  type: ClusterIP
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
```

**Communication:**
```
Frontend Pod → backend-api:8080 → Backend Pod
Backend Pod → mysql-service:3306 → MySQL Pod
```

---

## 2. NodePort Service 🚪

### What is NodePort?
- **External access** via Node IP
- Opens port on ALL nodes (30000-32767)
- Good for development/testing
- Not recommended for production

### Your NodePort Example:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-nodeport-service
spec:
  type: NodePort
  selector:
    app: my-app
  ports:
  - port: 80                   # Service port (internal)
    targetPort: 8080           # Pod port
    nodePort: 30007            # Node port (external)
```

### How it Works:

```
1. Service opens port 30007 on ALL nodes
   ↓
2. External request: http://NodeIP:30007
   ↓
3. Node forwards to Service (ClusterIP)
   ↓
4. Service routes to pod:8080
   ↓
5. Response back to user
```

### Port Mapping:

```
External → NodePort → Service Port → Target Port
:30007  →  :80      →  :8080
```

### When to Use:
- ✅ Development environment
- ✅ Testing
- ✅ Small deployments
- ❌ Production (use LoadBalancer instead)

### Real-World Example:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp-nodeport
spec:
  type: NodePort
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080            # Access via http://NodeIP:30080
```

**Access:**
```bash
# Get node IP
kubectl get nodes -o wide
# NODE-IP: 192.168.1.100

# Access from browser or curl
curl http://192.168.1.100:30080
```

---

## 3. LoadBalancer Service ☁️

### What is LoadBalancer?
- **Cloud load balancer** (AWS ELB, GCP LB, Azure LB)
- External IP address
- Production-ready
- Costs money (cloud provider charges)

### LoadBalancer Example:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 8080
```

### How it Works:

```
1. Kubernetes requests cloud load balancer
   ↓
2. Cloud provider creates LB
   ↓
3. LB gets external IP: 35.123.45.67
   ↓
4. User connects to 35.123.45.67:80
   ↓
5. LB routes to NodePort
   ↓
6. NodePort routes to Service
   ↓
7. Service routes to pods
```

### When to Use:
- ✅ Production websites
- ✅ Public APIs
- ✅ Cloud environments (AWS, GCP, Azure)
- ❌ On-premise (use Ingress instead)

### Real-World Example:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-website
spec:
  type: LoadBalancer
  selector:
    app: ecommerce
    tier: frontend
  ports:
  - name: http
    port: 80
    targetPort: 8080
  - name: https
    port: 443
    targetPort: 8443
```

**Result:**
```bash
kubectl get svc ecommerce-website
# NAME                TYPE           EXTERNAL-IP      PORT(S)
# ecommerce-website   LoadBalancer   35.123.45.67     80:30123/TCP,443:30124/TCP

# Access from anywhere:
curl http://35.123.45.67
```

---

## Service Types Comparison 📊

| Feature | ClusterIP | NodePort | LoadBalancer |
|---------|-----------|----------|--------------|
| **Access** | Internal only | External via Node IP | External via LB IP |
| **Port Range** | Any | 30000-32767 | Any |
| **Cost** | Free | Free | Paid (cloud) |
| **Production** | ✅ Yes | ❌ No | ✅ Yes |
| **Use Case** | Internal APIs | Development | Public apps |
| **Cloud Required** | ❌ No | ❌ No | ✅ Yes |

---

## Service Discovery 🔍

### DNS-Based Discovery:

```
Service Name: backend-api
Namespace: production

DNS Names:
- backend-api (same namespace)
- backend-api.production (cross-namespace)
- backend-api.production.svc.cluster.local (FQDN)
```

### Example:

```yaml
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
```

**Access from Frontend Pod:**
```bash
# Same namespace
curl http://backend-api:8080

# Different namespace
curl http://backend-api.production:8080

# Full DNS name
curl http://backend-api.production.svc.cluster.local:8080
```

---

## Real-World Scenario 1: Microservices 🏗️

### Scenario: E-commerce with 3 services

```yaml
# 1. Frontend Service (LoadBalancer - public)
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 3000
---
# 2. API Service (ClusterIP - internal)
apiVersion: v1
kind: Service
metadata:
  name: api
spec:
  type: ClusterIP
  selector:
    app: api
  ports:
  - port: 8080
    targetPort: 8080
---
# 3. Database Service (ClusterIP - internal)
apiVersion: v1
kind: Service
metadata:
  name: database
spec:
  type: ClusterIP
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
```

**Traffic Flow:**
```
User → LoadBalancer (frontend) → Frontend Pod
                                      ↓
                                  api:8080
                                      ↓
                                  API Pod
                                      ↓
                                database:3306
                                      ↓
                                  MySQL Pod
```

---

## Real-World Scenario 2: Multi-Port Service 🔌

### Scenario: Service with HTTP and HTTPS

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp
spec:
  type: LoadBalancer
  selector:
    app: webapp
  ports:
  - name: http
    port: 80
    targetPort: 8080
    protocol: TCP
  - name: https
    port: 443
    targetPort: 8443
    protocol: TCP
  - name: metrics
    port: 9090
    targetPort: 9090
    protocol: TCP
```

**Access:**
```bash
# HTTP
curl http://webapp:80

# HTTPS
curl https://webapp:443

# Metrics
curl http://webapp:9090/metrics
```

---

## Common Commands 🔧

```bash
# Create service
kubectl apply -f service.yml

# Get services
kubectl get svc
kubectl get services

# Describe service
kubectl describe svc my-service

# Get endpoints (pod IPs)
kubectl get endpoints my-service
kubectl get ep my-service

# Delete service
kubectl delete svc my-service

# Expose deployment as service
kubectl expose deployment my-app --type=NodePort --port=80

# Get service details
kubectl get svc my-service -o yaml

# Get external IP (LoadBalancer)
kubectl get svc my-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

---

## Troubleshooting 🔍

### Issue 1: Service has no endpoints

```bash
# Check service
kubectl get svc my-service

# Check endpoints
kubectl get endpoints my-service
# ENDPOINTS: <none>  ❌ Problem!

# Cause: Selector doesn't match pod labels

# Check service selector
kubectl get svc my-service -o yaml | grep -A 3 selector

# Check pod labels
kubectl get pods --show-labels

# Fix: Update service selector or pod labels
kubectl label pod my-pod app=my-app
```

### Issue 2: Can't access NodePort

```bash
# Check service
kubectl get svc my-service
# TYPE: NodePort
# PORT(S): 80:30007/TCP

# Check firewall
# Make sure port 30007 is open

# Check node IP
kubectl get nodes -o wide

# Test from node
ssh node-ip
curl localhost:30007

# If works on node but not externally:
# - Check firewall rules
# - Check security groups (cloud)
```

### Issue 3: LoadBalancer pending

```bash
# Check service
kubectl get svc my-service
# EXTERNAL-IP: <pending>  ❌ Stuck!

# Causes:
# 1. Not in cloud environment
# 2. Cloud provider not configured
# 3. Quota exceeded

# Check events
kubectl describe svc my-service

# Solution: Use NodePort or Ingress instead
```

---

## Best Practices 📚

### 1. Use ClusterIP for Internal Services
```yaml
# ✅ Good - Internal API
spec:
  type: ClusterIP

# ❌ Bad - Exposing internal API externally
spec:
  type: LoadBalancer
```

### 2. Name Ports
```yaml
# ✅ Good
ports:
- name: http
  port: 80
- name: https
  port: 443

# ❌ Bad
ports:
- port: 80
- port: 443
```

### 3. Use Specific Selectors
```yaml
# ✅ Good
selector:
  app: frontend
  tier: web
  environment: production

# ❌ Bad (too generic)
selector:
  app: app
```

### 4. Set Session Affinity (if needed)
```yaml
spec:
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
```

---

## Key Takeaways 🎯

1. **Service** = Stable network endpoint for pods
2. **ClusterIP** = Internal only (default)
3. **NodePort** = External via Node IP (dev/test)
4. **LoadBalancer** = Cloud LB (production)
5. **Selector** = Must match pod labels
6. **Endpoints** = List of pod IPs
7. **DNS** = Access by service name

---

**Services = Stable Access to Dynamic Pods! 🌐**
