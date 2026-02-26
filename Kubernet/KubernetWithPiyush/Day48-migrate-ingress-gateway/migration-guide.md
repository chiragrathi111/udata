# Ingress to Gateway API Migration Guide 🔄
## Complete Step-by-Step Migration

---

## What is Migration? 🤔

**Migration** means moving from old Ingress to new Gateway API while keeping your application running!

**Why Migrate?**
- ✅ Gateway API is the future
- ✅ More features and flexibility
- ✅ Better for teams
- ✅ Vendor neutral

---

## Before vs After 📊

### BEFORE (Ingress):

```
┌─────────────────────────────────────┐
│         Ingress Controller          │
├─────────────────────────────────────┤
│                                     │
│  ┌──────────────────────────────┐  │
│  │         Ingress              │  │
│  │  - Rules                     │  │
│  │  - TLS                       │  │
│  │  - Annotations (vendor!)     │  │
│  └──────────┬───────────────────┘  │
│             │                       │
│  ┌──────────▼───────────────────┐  │
│  │       Service                │  │
│  │       web-service            │  │
│  └──────────┬───────────────────┘  │
│             │                       │
│  ┌──────────▼───────────────────┐  │
│  │       Pods                   │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

### AFTER (Gateway API):

```
┌─────────────────────────────────────┐
│      Gateway API Controller         │
├─────────────────────────────────────┤
│                                     │
│  ┌──────────────────────────────┐  │
│  │       Gateway                │  │
│  │  - Listeners                 │  │
│  │  - TLS                       │  │
│  └──────────┬───────────────────┘  │
│             │                       │
│  ┌──────────▼───────────────────┐  │
│  │       HTTPRoute              │  │
│  │  - Path matching             │  │
│  │  - Backend refs              │  │
│  └──────────┬───────────────────┘  │
│             │                       │
│  ┌──────────▼───────────────────┐  │
│  │       Service                │  │
│  │       web-service            │  │
│  └──────────┬───────────────────┘  │
│             │                       │
│  ┌──────────▼───────────────────┐  │
│  │       Pods                   │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

---

## Your Project Structure 📁

```
Day48-migrate-ingress-gateway/
├── namespace.yml          ✅ NEW - Namespace
├── configmap.yml          ✅ Already have
├── deployment.yml         ✅ Already have
├── service.yml            ✅ Already have
├── tls-secret.yml         ✅ NEW - TLS Secret
│
├── ingress.yml            ✅ NEW - OLD WAY (Ingress)
│
├── gateway.yml            ✅ NEW - NEW WAY (Gateway)
└── httproute.yml          ✅ NEW - NEW WAY (HTTPRoute)
```

---

## Migration Strategy 🎯

### Strategy 1: Blue-Green Migration (Safest!)

```
Step 1: Keep Ingress running
Step 2: Deploy Gateway API alongside
Step 3: Test Gateway API
Step 4: Switch traffic to Gateway
Step 5: Remove Ingress

Timeline: Both run together, zero downtime!
```

### Strategy 2: Direct Migration (Faster)

```
Step 1: Delete Ingress
Step 2: Deploy Gateway API
Step 3: Test

Timeline: Small downtime (1-2 minutes)
```

**We'll use Strategy 1 (Blue-Green)!**

---

## Step-by-Step Migration 🚀

### Phase 1: Setup Current State (Ingress)

**Step 1: Create namespace**
```bash
kubectl apply -f namespace.yml
```

**Step 2: Deploy application**
```bash
kubectl apply -f configmap.yml
kubectl apply -f deployment.yml
kubectl apply -f service.yml
```

**Step 3: Create TLS secret**
```bash
kubectl apply -f tls-secret.yml
```

**Step 4: Deploy Ingress (OLD WAY)**
```bash
kubectl apply -f ingress.yml
```

**Step 5: Verify Ingress works**
```bash
# Check Ingress
kubectl get ingress -n web-app

# Test (if you have ingress controller)
curl http://web.example.com
# Or add to /etc/hosts:
# <ingress-ip> web.example.com
```

---

### Phase 2: Install Gateway API

**Step 1: Install Gateway API CRDs**
```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
```

**Step 2: Install Gateway Controller (NGINX)**
```bash
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.1.0/deploy/manifests/nginx-gateway.yaml
```

**Step 3: Verify installation**
```bash
kubectl get pods -n nginx-gateway
kubectl get gatewayclass
```

---

### Phase 3: Deploy Gateway API (NEW WAY)

**Step 1: Deploy Gateway**
```bash
kubectl apply -f gateway.yml
```

**Step 2: Check Gateway status**
```bash
kubectl get gateway -n web-app
kubectl describe gateway web-gateway -n web-app

# Wait for status: Programmed: True
```

**Step 3: Deploy HTTPRoute**
```bash
kubectl apply -f httproute.yml
```

**Step 4: Check HTTPRoute status**
```bash
kubectl get httproute -n web-app
kubectl describe httproute web-route -n web-app

# Look for: Accepted: True
```

---

### Phase 4: Test Both Systems

**Now you have BOTH running!**

```bash
# Check Ingress
kubectl get ingress -n web-app

# Check Gateway
kubectl get gateway -n web-app

# Check HTTPRoute
kubectl get httproute -n web-app

# Both point to same service!
```

**Test Gateway API:**
```bash
# Get Gateway IP
kubectl get gateway web-gateway -n web-app -o jsonpath='{.status.addresses[0].value}'

# Test
curl http://<gateway-ip> -H "Host: web.example.com"
```

---

### Phase 5: Switch Traffic

**Option A: DNS Switch (Production)**
```bash
# Change DNS from Ingress IP to Gateway IP
# Old: web.example.com → <ingress-ip>
# New: web.example.com → <gateway-ip>

# Wait for DNS propagation (5-60 minutes)
```

**Option B: Service Switch (Testing)**
```bash
# Change service to point to Gateway
# Or use different hostnames for testing
```

---

### Phase 6: Remove Ingress

**After Gateway API is working:**

```bash
# Delete Ingress
kubectl delete -f ingress.yml

# Verify Gateway still works
curl http://web.example.com

# If issues, quickly restore:
kubectl apply -f ingress.yml
```

---

## Complete Migration Commands 📝

```bash
# ============================================
# PHASE 1: Deploy with Ingress (OLD)
# ============================================

# 1. Create namespace
kubectl apply -f namespace.yml

# 2. Deploy app
kubectl apply -f configmap.yml
kubectl apply -f deployment.yml
kubectl apply -f service.yml
kubectl apply -f tls-secret.yml

# 3. Deploy Ingress
kubectl apply -f ingress.yml

# 4. Verify
kubectl get all -n web-app
kubectl get ingress -n web-app

# ============================================
# PHASE 2: Install Gateway API
# ============================================

# 1. Install CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

# 2. Install Controller
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.1.0/deploy/manifests/nginx-gateway.yaml

# 3. Verify
kubectl get pods -n nginx-gateway
kubectl get gatewayclass

# ============================================
# PHASE 3: Deploy Gateway API (NEW)
# ============================================

# 1. Deploy Gateway
kubectl apply -f gateway.yml

# 2. Wait for ready
kubectl wait --for=condition=Programmed gateway/web-gateway -n web-app --timeout=5m

# 3. Deploy HTTPRoute
kubectl apply -f httproute.yml

# 4. Verify
kubectl get gateway -n web-app
kubectl get httproute -n web-app

# ============================================
# PHASE 4: Test Both
# ============================================

# Test Ingress
kubectl get ingress -n web-app -o wide

# Test Gateway
kubectl get gateway -n web-app -o wide

# Both should work!

# ============================================
# PHASE 5: Switch Traffic (when ready)
# ============================================

# Get Gateway IP
GATEWAY_IP=$(kubectl get gateway web-gateway -n web-app -o jsonpath='{.status.addresses[0].value}')
echo "Gateway IP: $GATEWAY_IP"

# Update DNS or test with curl
curl http://$GATEWAY_IP -H "Host: web.example.com"

# ============================================
# PHASE 6: Remove Ingress (after testing)
# ============================================

# Delete Ingress
kubectl delete -f ingress.yml

# Verify Gateway still works
kubectl get gateway -n web-app
kubectl get httproute -n web-app

# Done! Migration complete! 🎉
```

---

## Side-by-Side Comparison 📋

### Ingress Configuration:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: web-app
  annotations:                              # ❌ Vendor-specific
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: web.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
  tls:
  - hosts:
    - web.example.com
    secretName: web-tls-secret
```

### Gateway API Configuration:

```yaml
# Gateway (Infrastructure)
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: web-app
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    hostname: "web.example.com"
  - name: https
    port: 443
    protocol: HTTPS
    hostname: "web.example.com"
    tls:
      mode: Terminate
      certificateRefs:
      - name: web-tls-secret
---
# HTTPRoute (Application)
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
  namespace: web-app
spec:
  parentRefs:
  - name: web-gateway
  hostnames:
  - "web.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web-service
      port: 80
```

---

## Benefits of Migration ✅

| Benefit | Description |
|---------|-------------|
| **Future-Proof** | Gateway API is the future of Kubernetes |
| **Vendor Neutral** | No more vendor-specific annotations |
| **More Features** | Traffic splitting, header routing, etc. |
| **Role Separation** | Ops manage Gateway, Devs manage Routes |
| **Better Multi-Tenancy** | Share Gateway across teams |
| **Easier to Understand** | Clear separation of concerns |
| **Standard API** | Works with any controller |

---

## Real-World Migration Example 🌍

### Scenario: E-commerce Platform

**Before (Ingress):**
```yaml
# One big Ingress for everything
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/rate-limit: "100"
    cert-manager.io/cluster-issuer: letsencrypt
spec:
  rules:
  - host: shop.example.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: frontend
            port:
              number: 80
      - path: /api
        backend:
          service:
            name: backend-api
            port:
              number: 8080
      - path: /admin
        backend:
          service:
            name: admin-panel
            port:
              number: 3000
```

**After (Gateway API):**
```yaml
# One Gateway (Ops team manages)
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: ecommerce-gateway
  namespace: gateway-system
spec:
  gatewayClassName: nginx
  listeners:
  - name: https
    port: 443
    protocol: HTTPS
    hostname: "shop.example.com"
    tls:
      certificateRefs:
      - name: shop-tls
---
# Frontend Route (Frontend team manages)
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: frontend-route
  namespace: frontend
spec:
  parentRefs:
  - name: ecommerce-gateway
    namespace: gateway-system
  hostnames:
  - "shop.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: frontend
      port: 80
---
# API Route (Backend team manages)
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: api-route
  namespace: backend
spec:
  parentRefs:
  - name: ecommerce-gateway
    namespace: gateway-system
  hostnames:
  - "shop.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: backend-api
      port: 8080
---
# Admin Route (Admin team manages)
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: admin-route
  namespace: admin
spec:
  parentRefs:
  - name: ecommerce-gateway
    namespace: gateway-system
  hostnames:
  - "shop.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /admin
    backendRefs:
    - name: admin-panel
      port: 3000
```

**Benefits:**
- ✅ Each team manages their own route
- ✅ Routes in separate namespaces
- ✅ One Gateway shared by all
- ✅ Easy to add/remove services
- ✅ No vendor-specific annotations

---

## Migration Checklist ✅

### Pre-Migration:
- [ ] Backup current Ingress configuration
- [ ] Document current setup
- [ ] Test current Ingress is working
- [ ] Install Gateway API CRDs
- [ ] Install Gateway Controller
- [ ] Verify GatewayClass exists

### During Migration:
- [ ] Deploy Gateway
- [ ] Verify Gateway is Programmed
- [ ] Deploy HTTPRoute
- [ ] Verify HTTPRoute is Accepted
- [ ] Test Gateway API works
- [ ] Compare Ingress vs Gateway responses
- [ ] Update monitoring/alerts

### Post-Migration:
- [ ] Switch DNS to Gateway
- [ ] Monitor traffic
- [ ] Verify no errors
- [ ] Delete Ingress
- [ ] Update documentation
- [ ] Train team on Gateway API

---

## Troubleshooting Migration 🔍

### Issue 1: Gateway not Programmed

```bash
# Check Gateway status
kubectl describe gateway web-gateway -n web-app

# Check controller logs
kubectl logs -n nginx-gateway -l app=nginx-gateway

# Common causes:
# - Controller not installed
# - GatewayClass doesn't exist
# - Invalid configuration
```

### Issue 2: HTTPRoute not Accepted

```bash
# Check HTTPRoute status
kubectl describe httproute web-route -n web-app

# Look for error messages in status

# Common causes:
# - Gateway doesn't exist
# - Wrong namespace
# - Service doesn't exist
```

### Issue 3: Traffic not routing

```bash
# Check service exists
kubectl get svc web-service -n web-app

# Check endpoints
kubectl get endpoints web-service -n web-app

# Check pods
kubectl get pods -n web-app

# Test directly
kubectl port-forward -n web-app svc/web-service 8080:80
curl localhost:8080
```

### Issue 4: TLS not working

```bash
# Check secret exists
kubectl get secret web-tls-secret -n web-app

# Check Gateway TLS config
kubectl get gateway web-gateway -n web-app -o yaml | grep -A 10 tls

# Verify certificate
kubectl get secret web-tls-secret -n web-app -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text
```

---

## Rollback Plan 🔙

**If Gateway API doesn't work:**

```bash
# Step 1: Keep Ingress running (don't delete it!)
kubectl get ingress -n web-app

# Step 2: Switch DNS back to Ingress
# Update DNS: web.example.com → <ingress-ip>

# Step 3: Delete Gateway API (optional)
kubectl delete -f httproute.yml
kubectl delete -f gateway.yml

# Step 4: Investigate issues
kubectl logs -n nginx-gateway -l app=nginx-gateway
```

---

## Best Practices 📚

### 1. Test in Non-Production First
```bash
# Migrate dev → staging → production
# Don't go straight to production!
```

### 2. Keep Both Running During Migration
```bash
# Blue-Green deployment
# Ingress + Gateway API together
# Switch when confident
```

### 3. Monitor Everything
```bash
# Watch logs
kubectl logs -n nginx-gateway -l app=nginx-gateway -f

# Watch Gateway status
kubectl get gateway -n web-app -w

# Watch HTTPRoute status
kubectl get httproute -n web-app -w
```

### 4. Document Changes
```bash
# Keep notes of:
# - What changed
# - When changed
# - Who changed
# - How to rollback
```

### 5. Train Your Team
```bash
# Gateway API is different from Ingress
# Make sure team understands:
# - Gateway vs HTTPRoute
# - Role separation
# - New commands
```

---

## Summary: Why Migrate? 🌟

| Reason | Impact |
|--------|--------|
| **Future-Proof** | Gateway API will replace Ingress |
| **Better Features** | Traffic splitting, header routing |
| **Team Friendly** | Ops and Dev work independently |
| **Vendor Neutral** | No lock-in to specific controller |
| **Easier Management** | Clear separation of concerns |
| **More Flexible** | Support for TCP, UDP, gRPC |
| **Standard API** | Works everywhere |

---

## Migration Timeline 📅

```
Week 1: Planning & Preparation
- Install Gateway API CRDs
- Install Gateway Controller
- Test in dev environment

Week 2: Dev Environment Migration
- Deploy Gateway API
- Test thoroughly
- Fix any issues

Week 3: Staging Environment Migration
- Deploy Gateway API
- Run load tests
- Verify performance

Week 4: Production Migration
- Deploy Gateway API alongside Ingress
- Monitor for 1 week
- Switch traffic gradually
- Remove Ingress

Total: 4 weeks for safe migration
```

---

**Migration = Moving to the Future of Kubernetes! 🚀**
