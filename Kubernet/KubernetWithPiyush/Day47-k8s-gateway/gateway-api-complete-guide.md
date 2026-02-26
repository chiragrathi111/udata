# Kubernetes Gateway API Complete Guide 🚪
## Why Gateway API is Better Than Ingress

---

## What is Gateway API? 🤔

**Gateway API** is the **next generation** of Kubernetes Ingress. It's more powerful, flexible, and easier to use!

**Think of it like this:**
- **Ingress** = Old flip phone (works but limited)
- **Gateway API** = Modern smartphone (powerful and flexible)

---

## Ingress vs Gateway API 🆚

### The Problem with Ingress:

```yaml
# Ingress (Old Way)
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:                    # ❌ Vendor-specific!
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: letsencrypt
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80

# Problems:
# ❌ Annotations are vendor-specific (nginx vs traefik)
# ❌ Limited features
# ❌ Hard to configure advanced routing
# ❌ No role separation (ops vs dev)
# ❌ Can't share infrastructure
```

### The Solution: Gateway API

```yaml
# Gateway API (New Way)
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: my-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: frontend-route
spec:
  parentRefs:
  - name: my-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: frontend
      port: 80

# Benefits:
# ✅ Standard API (works with any controller!)
# ✅ More features (header matching, traffic splitting)
# ✅ Role separation (ops manage Gateway, devs manage Routes)
# ✅ Can share Gateway across teams
# ✅ Better for multi-tenancy
```

---

## Key Differences Table 📊

| Feature | Ingress | Gateway API |
|---------|---------|-------------|
| **API Maturity** | Stable but limited | Modern & extensible |
| **Configuration** | Annotations (vendor-specific) | Native fields (standard) |
| **Role Separation** | No | Yes (Gateway vs Routes) |
| **Traffic Splitting** | Hard (annotations) | Easy (native) |
| **Header Routing** | Limited | Full support |
| **Multi-Protocol** | HTTP/HTTPS only | HTTP, HTTPS, TCP, UDP, gRPC |
| **Cross-Namespace** | Limited | Full support |
| **Vendor Lock-in** | High | Low |
| **Future-Proof** | No | Yes |

---

## Gateway API Architecture 🏗️

```
┌─────────────────────────────────────────────────────┐
│                  Gateway API                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────────────────────────┐          │
│  │      GatewayClass (Ops Team)         │          │
│  │  - Defines controller (nginx, istio) │          │
│  │  - Infrastructure config             │          │
│  └──────────────┬───────────────────────┘          │
│                 │                                   │
│  ┌──────────────▼───────────────────────┐          │
│  │      Gateway (Ops Team)              │          │
│  │  - Listeners (ports, protocols)      │          │
│  │  - TLS configuration                 │          │
│  │  - Shared infrastructure             │          │
│  └──────────────┬───────────────────────┘          │
│                 │                                   │
│  ┌──────────────▼───────────────────────┐          │
│  │      HTTPRoute (Dev Team)            │          │
│  │  - Path matching                     │          │
│  │  - Header matching                   │          │
│  │  - Backend services                  │          │
│  └──────────────┬───────────────────────┘          │
│                 │                                   │
│  ┌──────────────▼───────────────────────┐          │
│  │      Services & Pods                 │          │
│  │  - frontend-app                      │          │
│  │  - backend-api                       │          │
│  └──────────────────────────────────────┘          │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Gateway API Components 🧩

### 1. GatewayClass (Infrastructure Owner)

**What:** Defines which controller to use (nginx, istio, traefik)

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: k8s-gateway.nginx.org/nginx-gateway-controller
```

**Who manages:** Platform/Ops team
**Think of it as:** Choosing which brand of router to use

### 2. Gateway (Ops Team)

**What:** Actual load balancer/proxy instance

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: nginx-gateway
  namespace: nginx-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
```

**Who manages:** Ops team
**Think of it as:** The actual router hardware

### 3. HTTPRoute (Dev Team)

**What:** Routing rules for HTTP traffic

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: frontend-route
  namespace: default
spec:
  parentRefs:
  - name: nginx-gateway
    namespace: nginx-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: frontend-app
      port: 80
```

**Who manages:** Dev team
**Think of it as:** Setting up port forwarding rules

---

## Your Project Fixed! 🔧

### Complete Setup:

**1. GatewayClass (Usually pre-installed):**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: k8s-gateway.nginx.org/nginx-gateway-controller
```

**2. Gateway (gc.yml - already have):**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: nginx-gateway
  namespace: nginx-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
```

**3. Deployment (NEW - deployment.yml):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      run: frontend-app
  template:
    metadata:
      labels:
        run: frontend-app
    spec:
      containers:
      - name: frontend-app
        image: kodekloud/webapp-color
        ports:
        - containerPort: 8080
        env:
        - name: APP_COLOR
          value: "blue"
```

**4. Service (NEW - service.yml):**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-app
  namespace: default
spec:
  selector:
    run: frontend-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: ClusterIP
```

**5. HTTPRoute (FIXED - http.yml):**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: frontend-route
  namespace: default
spec:
  parentRefs:
    - name: nginx-gateway
      namespace: nginx-gateway
  rules:
    - matches:
      - path:
          type: PathPrefix
          value: /
      backendRefs:
        - name: frontend-app
          port: 80
```

### Deploy Order:

```bash
# 1. Create nginx-gateway namespace
kubectl create namespace nginx-gateway

# 2. Install Gateway API CRDs (if not installed)
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

# 3. Install NGINX Gateway Controller
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.1.0/deploy/manifests/nginx-gateway.yaml

# 4. Apply your files
kubectl apply -f gc.yml
kubectl apply -f deployment.yml
kubectl apply -f service.yml
kubectl apply -f http.yml

# 5. Check status
kubectl get gateway -n nginx-gateway
kubectl get httproute
kubectl get pods
kubectl get svc
```

---

## Real-World Example 1: Multi-Service Routing 🌐

### Scenario: Route different paths to different services

```
example.com/          → frontend-app
example.com/api/      → backend-api
example.com/admin/    → admin-panel
```

**Setup:**

```yaml
# Gateway (shared by all routes)
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: shared-gateway
  namespace: gateway-system
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
---
# Route 1: Frontend
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: frontend-route
  namespace: frontend
spec:
  parentRefs:
  - name: shared-gateway
    namespace: gateway-system
  hostnames:
  - "example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: frontend-app
      port: 80
---
# Route 2: Backend API
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: api-route
  namespace: backend
spec:
  parentRefs:
  - name: shared-gateway
    namespace: gateway-system
  hostnames:
  - "example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api/
    backendRefs:
    - name: backend-api
      port: 8080
---
# Route 3: Admin Panel
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: admin-route
  namespace: admin
spec:
  parentRefs:
  - name: shared-gateway
    namespace: gateway-system
  hostnames:
  - "example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /admin/
    backendRefs:
    - name: admin-panel
      port: 3000
```

**Benefits:**
- ✅ One Gateway, multiple routes
- ✅ Each team manages their own route
- ✅ Routes in different namespaces
- ✅ Easy to add/remove services

---

## Real-World Example 2: Traffic Splitting (Canary Deployment) 🐤

### Scenario: Send 90% traffic to v1, 10% to v2

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: canary-route
spec:
  parentRefs:
  - name: my-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: app-v1
      port: 80
      weight: 90        # 90% traffic
    - name: app-v2
      port: 80
      weight: 10        # 10% traffic (testing new version)
```

**With Ingress (Hard!):**
```yaml
# Need annotations, complex setup
annotations:
  nginx.ingress.kubernetes.io/canary: "true"
  nginx.ingress.kubernetes.io/canary-weight: "10"
```

---

## Real-World Example 3: Header-Based Routing 🎯

### Scenario: Route based on headers (A/B testing)

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: ab-testing-route
spec:
  parentRefs:
  - name: my-gateway
  rules:
  # Beta users (header: X-User-Type: beta)
  - matches:
    - headers:
      - name: X-User-Type
        value: beta
    backendRefs:
    - name: app-beta
      port: 80
  
  # Regular users (default)
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: app-stable
      port: 80
```

**With Ingress:** Nearly impossible without complex annotations!

---

## Real-World Example 4: Multi-Domain Routing 🌍

### Scenario: Multiple domains on same Gateway

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: multi-domain-route
spec:
  parentRefs:
  - name: my-gateway
  hostnames:
  - "app1.example.com"
  - "app2.example.com"
  - "app3.example.com"
  rules:
  # app1.example.com → service1
  - matches:
    - headers:
      - name: :authority
        value: app1.example.com
    backendRefs:
    - name: service1
      port: 80
  
  # app2.example.com → service2
  - matches:
    - headers:
      - name: :authority
        value: app2.example.com
    backendRefs:
    - name: service2
      port: 80
  
  # app3.example.com → service3
  - matches:
    - headers:
      - name: :authority
        value: app3.example.com
    backendRefs:
    - name: service3
      port: 80
```

---

## Benefits of Gateway API ✅

### 1. Role Separation
```
Ops Team:
- Manages GatewayClass
- Manages Gateway
- Controls infrastructure

Dev Team:
- Manages HTTPRoute
- Defines routing rules
- No access to infrastructure
```

### 2. Vendor Neutral
```yaml
# Works with ANY controller!
gatewayClassName: nginx      # NGINX
gatewayClassName: istio      # Istio
gatewayClassName: traefik    # Traefik
gatewayClassName: envoy      # Envoy

# No vendor-specific annotations needed!
```

### 3. Advanced Routing
```yaml
# Easy traffic splitting
weight: 90
weight: 10

# Header matching
headers:
- name: X-User-Type
  value: premium

# Query parameter matching
queryParams:
- name: version
  value: v2
```

### 4. Better Multi-Tenancy
```yaml
# One Gateway, multiple teams
allowedRoutes:
  namespaces:
    from: All

# Each team manages their own routes
# in their own namespace
```

### 5. Future-Proof
```
Gateway API is:
✅ Actively developed
✅ Backed by Kubernetes SIG
✅ Will replace Ingress
✅ More features coming
```

---

## Migration: Ingress → Gateway API 🔄

### Before (Ingress):

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

### After (Gateway API):

```yaml
# Gateway (create once, reuse)
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: my-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
---
# HTTPRoute (per app)
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-app-route
spec:
  parentRefs:
  - name: my-gateway
  hostnames:
  - "example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /app
    backendRefs:
    - name: my-service
      port: 80
```

---

## Common Commands 🔧

```bash
# Install Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

# Check GatewayClass
kubectl get gatewayclass

# Check Gateways
kubectl get gateway -A

# Check HTTPRoutes
kubectl get httproute -A

# Describe Gateway
kubectl describe gateway nginx-gateway -n nginx-gateway

# Describe HTTPRoute
kubectl describe httproute frontend-route

# Check Gateway status
kubectl get gateway nginx-gateway -n nginx-gateway -o yaml

# Check if route is attached
kubectl get httproute frontend-route -o yaml

# Get Gateway IP/Hostname
kubectl get gateway nginx-gateway -n nginx-gateway -o jsonpath='{.status.addresses[0].value}'

# Test routing
curl http://<gateway-ip>/
```

---

## Troubleshooting 🔍

### Issue 1: Gateway not ready

```bash
# Check Gateway status
kubectl describe gateway nginx-gateway -n nginx-gateway

# Check controller pods
kubectl get pods -n nginx-gateway

# Check logs
kubectl logs -n nginx-gateway <controller-pod>
```

### Issue 2: HTTPRoute not working

```bash
# Check if route is attached to gateway
kubectl get httproute frontend-route -o yaml

# Look for status.parents section
# Should show: Accepted: True

# Check service exists
kubectl get svc frontend-app

# Check endpoints
kubectl get endpoints frontend-app
```

### Issue 3: 404 errors

```bash
# Check path matching
# PathPrefix: /api matches /api, /api/users
# Exact: /api matches only /api

# Check hostname
# If hostname specified, must match Host header
```

---

## Best Practices 📚

### 1. Use One Gateway per Environment
```yaml
# Production Gateway
name: prod-gateway
namespace: gateway-prod

# Staging Gateway
name: staging-gateway
namespace: gateway-staging
```

### 2. Separate Ops and Dev Concerns
```yaml
# Ops manages Gateway
namespace: gateway-system

# Devs manage Routes
namespace: app-team-1
namespace: app-team-2
```

### 3. Use Hostnames for Multi-Tenancy
```yaml
hostnames:
- "team1.example.com"
- "team2.example.com"
```

### 4. Start Simple, Add Features Later
```yaml
# Start with basic routing
- matches:
  - path:
      type: PathPrefix
      value: /

# Add features as needed
# - Traffic splitting
# - Header matching
# - TLS
```

---

## Summary: Why Gateway API? 🌟

| Reason | Benefit |
|--------|---------|
| **Standard API** | Works with any controller |
| **Role Separation** | Ops and Dev teams work independently |
| **Advanced Features** | Traffic splitting, header routing, etc. |
| **Future-Proof** | Will replace Ingress |
| **Better Multi-Tenancy** | Share infrastructure safely |
| **Vendor Neutral** | No lock-in |
| **Easier to Use** | No complex annotations |

---

## When to Use What? 🤔

### Use Ingress if:
- ❌ Simple use case
- ❌ Already using Ingress (no need to migrate yet)
- ❌ Team not ready for new API

### Use Gateway API if:
- ✅ New project
- ✅ Need advanced routing
- ✅ Multi-team environment
- ✅ Want future-proof solution
- ✅ Need vendor neutrality

---

**Gateway API = The Future of Kubernetes Ingress! 🚀**
