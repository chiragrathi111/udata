# Kubernetes Namespaces Complete Guide 🏢
## Multi-Tenancy & Resource Isolation

---

## What is a Namespace? 🤔

**Namespace** is a virtual cluster inside your Kubernetes cluster. It provides logical separation of resources.

**Think of it like:**
- Apartment building = Kubernetes cluster
- Each apartment = Namespace
- Tenants don't see each other's stuff
- Shared building infrastructure

**Simple Example:**
```
Cluster
├── default (namespace)
│   ├── pod1
│   └── pod2
├── dev (namespace)
│   ├── pod1
│   └── pod2
└── production (namespace)
    ├── pod1
    └── pod2
```

---

## Why Use Namespaces? 💡

### Benefits:
1. **Resource Isolation** - Separate teams/projects
2. **Access Control** - RBAC per namespace
3. **Resource Quotas** - Limit CPU/memory per namespace
4. **Environment Separation** - dev/staging/prod
5. **Name Collision Prevention** - Same names in different namespaces

### When to Use:
- ✅ Multiple teams sharing cluster
- ✅ Multiple environments (dev/staging/prod)
- ✅ Multiple projects
- ✅ Resource quota enforcement
- ✅ Access control per team

### When NOT to Use:
- ❌ Single small project
- ❌ Learning/testing
- ❌ Very small clusters

---

## Default Namespaces 📦

Kubernetes comes with 4 default namespaces:

### 1. default
**What:** Default namespace for resources
**Use:** When you don't specify namespace
```bash
kubectl get pods
# Shows pods in 'default' namespace
```

### 2. kube-system
**What:** Kubernetes system components
**Use:** Core cluster services
```bash
kubectl get pods -n kube-system
# Shows: kube-proxy, coredns, etc.
```

### 3. kube-public
**What:** Publicly accessible resources
**Use:** ConfigMaps readable by all
```bash
kubectl get configmap -n kube-public
```

### 4. kube-node-lease
**What:** Node heartbeat information
**Use:** Node health tracking
```bash
kubectl get leases -n kube-node-lease
```

---

## Creating Namespaces 🛠️

### Method 1: YAML (Declarative)

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
  labels:
    environment: development
    team: backend
```

```bash
kubectl apply -f namespace.yml
```

### Method 2: Command (Imperative)

```bash
# Create namespace
kubectl create namespace dev
# OR
kubectl create ns dev

# With labels
kubectl create namespace dev --dry-run=client -o yaml | \
  kubectl label --local -f - environment=development -o yaml | \
  kubectl apply -f -
```

---

## Working with Namespaces 🔧

### Basic Commands:

```bash
# List all namespaces
kubectl get namespaces
kubectl get ns

# Describe namespace
kubectl describe ns dev

# Delete namespace (deletes all resources inside!)
kubectl delete ns dev

# Get resources in namespace
kubectl get all -n dev
kubectl get pods -n dev
kubectl get svc -n dev

# Create resource in namespace
kubectl apply -f pod.yml -n dev

# Set default namespace for current context
kubectl config set-context --current --namespace=dev

# Get current namespace
kubectl config view --minify | grep namespace:
```

---

## Namespace Scope 📊

### Namespaced Resources:
These resources belong to a namespace:
- Pods
- Services
- Deployments
- ConfigMaps
- Secrets
- PersistentVolumeClaims

```bash
# List namespaced resources
kubectl api-resources --namespaced=true
```

### Cluster-Scoped Resources:
These resources are cluster-wide:
- Nodes
- PersistentVolumes
- StorageClasses
- Namespaces themselves

```bash
# List cluster-scoped resources
kubectl api-resources --namespaced=false
```

---

## Real-World Scenario 1: Multi-Environment 🌍

### Scenario: Dev, Staging, Production

```yaml
# 1. Development Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: dev
  labels:
    environment: development
---
# 2. Staging Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: staging
  labels:
    environment: staging
---
# 3. Production Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: production
```

**Deploy same app to different environments:**

```bash
# Deploy to dev
kubectl apply -f app.yml -n dev

# Deploy to staging
kubectl apply -f app.yml -n staging

# Deploy to production
kubectl apply -f app.yml -n production

# Each environment isolated!
```

---

## Real-World Scenario 2: Multi-Team 👥

### Scenario: Frontend, Backend, Data teams

```yaml
# 1. Frontend Team Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: team-frontend
  labels:
    team: frontend
---
# 2. Backend Team Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: team-backend
  labels:
    team: backend
---
# 3. Data Team Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: team-data
  labels:
    team: data
```

**Benefits:**
- Each team has own namespace
- Can't accidentally delete other team's resources
- Separate resource quotas
- Separate access control

---

## Resource Quotas 💰

### Limit resources per namespace:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: dev
spec:
  hard:
    requests.cpu: "10"           # Max 10 CPU cores
    requests.memory: 20Gi        # Max 20GB RAM
    limits.cpu: "20"
    limits.memory: 40Gi
    pods: "50"                   # Max 50 pods
    services: "10"               # Max 10 services
    persistentvolumeclaims: "5"  # Max 5 PVCs
```

```bash
# Apply quota
kubectl apply -f quota.yml

# Check quota usage
kubectl get resourcequota -n dev
kubectl describe resourcequota dev-quota -n dev
```

**Example Output:**
```
Resource         Used   Hard
--------         ----   ----
pods             10     50
requests.cpu     5      10
requests.memory  10Gi   20Gi
```

---

## LimitRange 📏

### Set default limits for pods:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: dev-limits
  namespace: dev
spec:
  limits:
  - max:
      cpu: "2"
      memory: 2Gi
    min:
      cpu: 100m
      memory: 128Mi
    default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 200m
      memory: 256Mi
    type: Container
```

**What it does:**
- Sets default CPU/memory if not specified
- Enforces min/max limits
- Prevents resource hogging

---

## Cross-Namespace Communication 🔗

### Accessing services across namespaces:

```yaml
# Service in 'backend' namespace
apiVersion: v1
kind: Service
metadata:
  name: api-service
  namespace: backend
spec:
  selector:
    app: api
  ports:
  - port: 8080
```

**Access from different namespace:**

```bash
# From same namespace (backend)
curl http://api-service:8080

# From different namespace (frontend)
curl http://api-service.backend:8080

# Full DNS name (any namespace)
curl http://api-service.backend.svc.cluster.local:8080
```

**DNS Format:**
```
<service-name>.<namespace>.svc.cluster.local
```

---

## Network Policies with Namespaces 🔒

### Isolate namespaces:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-from-other-namespaces
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector: {}        # Allow from same namespace only
```

**Result:**
- Pods in 'production' can only talk to each other
- Pods from 'dev' or 'staging' blocked
- Secure production environment!

---

## RBAC with Namespaces 🔐

### Give team access to their namespace only:

```yaml
# Role in 'team-frontend' namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: team-frontend
rules:
- apiGroups: ["", "apps"]
  resources: ["pods", "deployments", "services"]
  verbs: ["get", "list", "create", "update", "delete"]
---
# Bind role to user
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: team-frontend
subjects:
- kind: User
  name: john@example.com
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

**Result:**
- John can manage resources in 'team-frontend'
- John cannot access 'team-backend' or 'production'
- Secure multi-tenancy!

---

## Best Practices 📚

### 1. Use Meaningful Names
```yaml
# ✅ Good
name: team-frontend-prod
name: project-ecommerce-dev

# ❌ Bad
name: ns1
name: test
```

### 2. Add Labels
```yaml
metadata:
  name: production
  labels:
    environment: production
    team: platform
    cost-center: engineering
```

### 3. Set Resource Quotas
```yaml
# Always set quotas in shared clusters
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-quota
  namespace: team-frontend
```

### 4. Use Namespace in YAML
```yaml
# ✅ Good - Explicit namespace
metadata:
  name: my-app
  namespace: production

# ❌ Bad - Relies on context
metadata:
  name: my-app
```

### 5. Don't Use 'default' Namespace
```bash
# ❌ Bad
kubectl apply -f app.yml

# ✅ Good
kubectl apply -f app.yml -n production
```

---

## Common Patterns 🎯

### Pattern 1: Environment-Based

```
Cluster
├── dev
├── staging
└── production
```

### Pattern 2: Team-Based

```
Cluster
├── team-frontend
├── team-backend
├── team-data
└── team-platform
```

### Pattern 3: Project-Based

```
Cluster
├── project-ecommerce
├── project-analytics
└── project-mobile-api
```

### Pattern 4: Hybrid

```
Cluster
├── ecommerce-dev
├── ecommerce-staging
├── ecommerce-prod
├── analytics-dev
└── analytics-prod
```

---

## Troubleshooting 🔍

### Issue 1: Can't find resources

```bash
# Check current namespace
kubectl config view --minify | grep namespace:

# List all namespaces
kubectl get ns

# Check resource in specific namespace
kubectl get pods -n dev

# Check all namespaces
kubectl get pods --all-namespaces
kubectl get pods -A
```

### Issue 2: Quota exceeded

```bash
# Check quota
kubectl describe resourcequota -n dev

# See what's using resources
kubectl top pods -n dev

# Delete unused resources
kubectl delete pod <pod-name> -n dev
```

### Issue 3: Can't delete namespace

```bash
# Namespace stuck in 'Terminating'
kubectl get ns
# dev   Terminating   5m

# Check what's blocking
kubectl get all -n dev

# Force delete (careful!)
kubectl delete ns dev --grace-period=0 --force

# Or remove finalizers
kubectl get ns dev -o json | \
  jq '.spec.finalizers = []' | \
  kubectl replace --raw "/api/v1/namespaces/dev/finalize" -f -
```

---

## Real-World Example: Complete Setup 🏗️

```yaml
# 1. Create namespace
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce-prod
  labels:
    environment: production
    project: ecommerce
---
# 2. Set resource quota
apiVersion: v1
kind: ResourceQuota
metadata:
  name: prod-quota
  namespace: ecommerce-prod
spec:
  hard:
    requests.cpu: "20"
    requests.memory: 40Gi
    pods: "100"
---
# 3. Set limit range
apiVersion: v1
kind: LimitRange
metadata:
  name: prod-limits
  namespace: ecommerce-prod
spec:
  limits:
  - max:
      cpu: "4"
      memory: 4Gi
    min:
      cpu: 100m
      memory: 128Mi
    default:
      cpu: 500m
      memory: 512Mi
    type: Container
---
# 4. Network policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
  namespace: ecommerce-prod
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector: {}
---
# 5. RBAC
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: ecommerce-prod
rules:
- apiGroups: ["", "apps"]
  resources: ["pods", "deployments", "services"]
  verbs: ["get", "list", "watch"]
```

---

## Namespace Lifecycle 🔄

```
1. Create namespace
   ↓
2. Set quotas and limits
   ↓
3. Configure RBAC
   ↓
4. Deploy applications
   ↓
5. Monitor resource usage
   ↓
6. Scale/update as needed
   ↓
7. Delete namespace (when done)
   ↓
8. All resources deleted automatically
```

---

## Key Takeaways 🎯

1. **Namespace** = Virtual cluster for isolation
2. **Use for** = Multi-team, multi-environment
3. **Resource Quotas** = Limit resources per namespace
4. **RBAC** = Control access per namespace
5. **DNS** = service-name.namespace.svc.cluster.local
6. **Don't use 'default'** = Create specific namespaces
7. **Delete namespace** = Deletes all resources inside

---

**Namespaces = Multi-Tenancy Made Easy! 🏢**
