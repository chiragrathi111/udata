# Kustomize Complete Guide 🚀
## From Beginner to Pro with Real Examples

---

## What is Kustomize? 🤔

**Kustomize** is a tool built into kubectl that lets you customize Kubernetes YAML files WITHOUT modifying the original files!

**Think of it like this:**
- You have base YAML files (original recipes)
- Kustomize adds/changes things (customizes the recipe)
- You get final YAML (ready to cook!)
- Original files stay untouched! ✅

---

## Why Use Kustomize? 💡

### Problem WITHOUT Kustomize:

```bash
# You have 3 environments: dev, staging, production
# Each needs different configurations

my-app/
├── dev-deployment.yaml       # Copy-paste, change values
├── staging-deployment.yaml   # Copy-paste, change values
├── prod-deployment.yaml      # Copy-paste, change values
└── ...

# Problems:
# ❌ Lots of duplicate code
# ❌ Hard to maintain (change in 3 places!)
# ❌ Easy to make mistakes
# ❌ Difficult to see differences
```

### Solution WITH Kustomize:

```bash
my-app/
├── base/                     # Original files (one copy!)
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
├── overlays/
│   ├── dev/                  # Only differences for dev
│   │   └── kustomization.yaml
│   ├── staging/              # Only differences for staging
│   │   └── kustomization.yaml
│   └── production/           # Only differences for prod
│       └── kustomization.yaml

# Benefits:
# ✅ One base file, multiple environments
# ✅ Easy to maintain
# ✅ Clear what's different
# ✅ No duplication!
```

---

## Real-World Example 1: Simple 3-Tier App 🏗️

### Your Current Setup (What you have):

```
Day44-Kustomize/
├── db/
│   ├── db-config.yaml
│   ├── db-depl.yaml
│   ├── db-service.yaml
│   └── kustomization.yaml
├── message-broker/
│   ├── rabbitmq-config.yaml
│   ├── rabbitmq-depl.yaml
│   ├── rabbitmq-service.yaml
│   └── kustomization.yaml
├── nginx/
│   ├── nginx-depl.yaml
│   ├── nginx-service.yaml
│   └── kustomization.yaml
└── kustomization.yaml        # Main file
```

### How It Works:

**Step 1: Each folder has kustomization.yaml**

```yaml
# db/kustomization.yaml
resources:
  - db-config.yaml
  - db-depl.yaml
  - db-service.yaml
```

**Step 2: Main kustomization.yaml combines all**

```yaml
# kustomization.yaml (root)
resources:
  - db/
  - message-broker/
  - nginx/
```

**Step 3: Apply everything with ONE command!**

```bash
kubectl kustomize . | kubectl apply -f -

# This applies:
# - All db files
# - All message-broker files
# - All nginx files
# In ONE command! 🎉
```

---

## Real-World Example 2: Multiple Environments 🌍

### Scenario: Same app, different environments

```
my-webapp/
├── base/                           # Common for all environments
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── kustomization.yaml
└── overlays/
    ├── dev/                        # Development environment
    │   ├── kustomization.yaml
    │   └── replica-patch.yaml
    ├── staging/                    # Staging environment
    │   ├── kustomization.yaml
    │   └── replica-patch.yaml
    └── production/                 # Production environment
        ├── kustomization.yaml
        ├── replica-patch.yaml
        └── resource-limits.yaml
```

### Base Files (Common):

**base/deployment.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 1                    # Default
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: myapp:latest
        ports:
        - containerPort: 8080
```

**base/service.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

**base/kustomization.yaml**
```yaml
resources:
  - deployment.yaml
  - service.yaml
```

### Dev Environment (2 replicas):

**overlays/dev/kustomization.yaml**
```yaml
# Use base files
bases:
  - ../../base

# Add namespace
namespace: dev

# Add labels to everything
commonLabels:
  environment: dev

# Change replicas to 2
replicas:
  - name: webapp
    count: 2

# Add prefix to all resources
namePrefix: dev-
```

**Apply Dev:**
```bash
kubectl kustomize overlays/dev | kubectl apply -f -

# Result:
# - Name: dev-webapp (prefix added!)
# - Namespace: dev
# - Replicas: 2
# - Labels: environment=dev
```

### Production Environment (5 replicas + limits):

**overlays/production/kustomization.yaml**
```yaml
bases:
  - ../../base

namespace: production

commonLabels:
  environment: production

replicas:
  - name: webapp
    count: 5                    # 5 replicas for production!

namePrefix: prod-

# Add resource limits (production only!)
patchesStrategicMerge:
  - resource-limits.yaml
```

**overlays/production/resource-limits.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  template:
    spec:
      containers:
      - name: webapp
        resources:
          limits:
            cpu: "1000m"
            memory: "1Gi"
          requests:
            cpu: "500m"
            memory: "512Mi"
```

**Apply Production:**
```bash
kubectl kustomize overlays/production | kubectl apply -f -

# Result:
# - Name: prod-webapp
# - Namespace: production
# - Replicas: 5
# - Resource limits added!
# - Labels: environment=production
```

---

## Real-World Example 3: ConfigMap Changes 📝

### Scenario: Different database URLs per environment

**base/configmap.yaml**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_URL: "localhost:5432"
  LOG_LEVEL: "info"
```

**overlays/dev/kustomization.yaml**
```yaml
bases:
  - ../../base

# Replace ConfigMap values for dev
configMapGenerator:
  - name: app-config
    behavior: replace
    literals:
      - DATABASE_URL=dev-db.example.com:5432
      - LOG_LEVEL=debug              # Debug logs in dev!
```

**overlays/production/kustomization.yaml**
```yaml
bases:
  - ../../base

# Replace ConfigMap values for production
configMapGenerator:
  - name: app-config
    behavior: replace
    literals:
      - DATABASE_URL=prod-db.example.com:5432
      - LOG_LEVEL=error              # Only errors in prod!
```

---

## Kustomize Features Explained 🎯

### 1. Resources
**What:** List of YAML files to include

```yaml
resources:
  - deployment.yaml
  - service.yaml
  - configmap.yaml
```

### 2. Bases
**What:** Reference to other kustomization directories

```yaml
bases:
  - ../../base
  - ../common
```

### 3. NamePrefix / NameSuffix
**What:** Add prefix/suffix to all resource names

```yaml
namePrefix: dev-        # dev-webapp, dev-service
nameSuffix: -v2         # webapp-v2, service-v2
```

### 4. Namespace
**What:** Set namespace for all resources

```yaml
namespace: production
```

### 5. CommonLabels
**What:** Add labels to all resources

```yaml
commonLabels:
  environment: production
  team: backend
  version: v1.0
```

### 6. CommonAnnotations
**What:** Add annotations to all resources

```yaml
commonAnnotations:
  managed-by: kustomize
  contact: team@example.com
```

### 7. Replicas
**What:** Change replica count

```yaml
replicas:
  - name: webapp
    count: 5
  - name: api
    count: 3
```

### 8. Images
**What:** Change container images

```yaml
images:
  - name: myapp
    newName: myregistry.com/myapp
    newTag: v2.0.0
```

### 9. ConfigMapGenerator
**What:** Generate ConfigMaps

```yaml
configMapGenerator:
  - name: app-config
    literals:
      - DATABASE_URL=db.example.com
      - API_KEY=abc123
    files:
      - config.json
      - app.properties
```

### 10. SecretGenerator
**What:** Generate Secrets

```yaml
secretGenerator:
  - name: db-secret
    literals:
      - username=admin
      - password=secret123
```

### 11. PatchesStrategicMerge
**What:** Merge patches into resources

```yaml
patchesStrategicMerge:
  - resource-limits.yaml
  - env-vars.yaml
```

### 12. PatchesJson6902
**What:** JSON patches (advanced)

```yaml
patchesJson6902:
  - target:
      group: apps
      version: v1
      kind: Deployment
      name: webapp
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 3
```

---

## Real-World Example 4: Multi-Region Deployment 🌐

### Scenario: Deploy to US, EU, Asia regions

```
my-app/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── regions/
    ├── us-east/
    │   └── kustomization.yaml
    ├── eu-west/
    │   └── kustomization.yaml
    └── asia-south/
        └── kustomization.yaml
```

**regions/us-east/kustomization.yaml**
```yaml
bases:
  - ../../base

namespace: us-east

commonLabels:
  region: us-east
  datacenter: virginia

# US-specific image registry
images:
  - name: myapp
    newName: us.gcr.io/myapp
    newTag: latest

# US-specific config
configMapGenerator:
  - name: app-config
    behavior: merge
    literals:
      - REGION=us-east
      - TIMEZONE=America/New_York
      - CDN_URL=https://cdn-us.example.com
```

**regions/eu-west/kustomization.yaml**
```yaml
bases:
  - ../../base

namespace: eu-west

commonLabels:
  region: eu-west
  datacenter: ireland

# EU-specific image registry
images:
  - name: myapp
    newName: eu.gcr.io/myapp
    newTag: latest

# EU-specific config
configMapGenerator:
  - name: app-config
    behavior: merge
    literals:
      - REGION=eu-west
      - TIMEZONE=Europe/Dublin
      - CDN_URL=https://cdn-eu.example.com
```

**Deploy to all regions:**
```bash
# Deploy to US
kubectl kustomize regions/us-east | kubectl apply -f -

# Deploy to EU
kubectl kustomize regions/eu-west | kubectl apply -f -

# Deploy to Asia
kubectl kustomize regions/asia-south | kubectl apply -f -
```

---

## Real-World Example 5: Feature Flags 🚩

### Scenario: Enable/disable features per environment

**base/deployment.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: myapp:latest
        env:
        - name: FEATURE_NEW_UI
          value: "false"
        - name: FEATURE_BETA_API
          value: "false"
```

**overlays/dev/kustomization.yaml**
```yaml
bases:
  - ../../base

# Enable all features in dev!
patchesStrategicMerge:
  - |-
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      template:
        spec:
          containers:
          - name: webapp
            env:
            - name: FEATURE_NEW_UI
              value: "true"
            - name: FEATURE_BETA_API
              value: "true"
            - name: FEATURE_EXPERIMENTAL
              value: "true"
```

**overlays/production/kustomization.yaml**
```yaml
bases:
  - ../../base

# Only stable features in production
patchesStrategicMerge:
  - |-
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      template:
        spec:
          containers:
          - name: webapp
            env:
            - name: FEATURE_NEW_UI
              value: "true"          # Only this enabled
            - name: FEATURE_BETA_API
              value: "false"         # Not ready yet
```

---

## Common Kustomize Commands 🔧

```bash
# 1. Preview what will be applied (DRY RUN)
kubectl kustomize .

# 2. Apply kustomization
kubectl kustomize . | kubectl apply -f -

# 3. Delete resources
kubectl kustomize . | kubectl delete -f -

# 4. Preview specific overlay
kubectl kustomize overlays/production

# 5. Apply specific overlay
kubectl kustomize overlays/production | kubectl apply -f -

# 6. Save output to file
kubectl kustomize . > output.yaml

# 7. Validate kustomization
kubectl kustomize . --enable-alpha-plugins

# 8. Use with kubectl apply directly (built-in!)
kubectl apply -k .
kubectl apply -k overlays/production

# 9. Delete with kubectl
kubectl delete -k .
kubectl delete -k overlays/dev
```

---

## Best Practices 📚

### 1. Directory Structure
```
project/
├── base/                    # Common resources
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays/                # Environment-specific
    ├── dev/
    ├── staging/
    └── production/
```

### 2. Keep Base Simple
```yaml
# base/kustomization.yaml
# Only list resources, no customizations
resources:
  - deployment.yaml
  - service.yaml
  - configmap.yaml
```

### 3. Use Overlays for Differences
```yaml
# overlays/production/kustomization.yaml
bases:
  - ../../base

# Only production-specific changes
replicas:
  - name: webapp
    count: 10

resources:
  - ingress.yaml              # Production-only resource
```

### 4. Use ConfigMapGenerator
```yaml
# Better than hardcoding in YAML
configMapGenerator:
  - name: app-config
    files:
      - config.properties
      - database.conf
```

### 5. Version Control
```bash
# Commit base and overlays
git add base/ overlays/
git commit -m "Add kustomize structure"

# Don't commit generated files
echo "output.yaml" >> .gitignore
```

---

## Kustomize vs Helm 🆚

| Feature | Kustomize | Helm |
|---------|-----------|------|
| **Learning Curve** | Easy ✅ | Moderate |
| **Template Language** | No templates! Pure YAML | Go templates |
| **Built into kubectl** | Yes ✅ | No (separate tool) |
| **Package Management** | No | Yes (charts) |
| **Best For** | Simple customization | Complex apps with dependencies |
| **Reusability** | Overlays | Charts repository |

**When to use Kustomize:**
- ✅ Simple apps
- ✅ Multiple environments
- ✅ Don't want to learn templating
- ✅ Want to keep pure YAML

**When to use Helm:**
- ✅ Complex apps
- ✅ Need package management
- ✅ Want to share with community
- ✅ Need dependencies

---

## Quick Reference Card 📋

```yaml
# Basic kustomization.yaml structure
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# Include other kustomizations
bases:
  - ../../base

# List YAML files
resources:
  - deployment.yaml
  - service.yaml

# Change namespace
namespace: production

# Add prefix/suffix to names
namePrefix: prod-
nameSuffix: -v2

# Add labels to everything
commonLabels:
  env: production
  team: backend

# Change replicas
replicas:
  - name: webapp
    count: 5

# Change images
images:
  - name: myapp
    newTag: v2.0.0

# Generate ConfigMap
configMapGenerator:
  - name: config
    literals:
      - KEY=value

# Generate Secret
secretGenerator:
  - name: secret
    literals:
      - PASSWORD=secret123

# Apply patches
patchesStrategicMerge:
  - patch.yaml
```

---

## Troubleshooting Common Issues 🔍

### Issue 1: "no matches for kind"
```bash
# Error: no matches for kind "Configmap"
# Fix: Use correct case
kind: ConfigMap    # ✅ Capital M
kind: Configmap    # ❌ Wrong
```

### Issue 2: "resource not found"
```bash
# Error: deployment.yaml not found
# Fix: Check path in kustomization.yaml
resources:
  - deployment.yaml    # ✅ Correct path
  - deploy.yaml        # ❌ Wrong filename
```

### Issue 3: "duplicate resource"
```bash
# Error: duplicate resource
# Fix: Don't list same file twice
resources:
  - deployment.yaml
  - deployment.yaml    # ❌ Duplicate!
```

### Issue 4: "field not found"
```bash
# Error: unknown field "protocal"
# Fix: Check spelling
protocol: TCP    # ✅ Correct
protocal: TCP    # ❌ Typo
```

---

## Real Production Example 🏭

### Complete E-commerce App

```
ecommerce/
├── base/
│   ├── frontend/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── kustomization.yaml
│   ├── backend/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── kustomization.yaml
│   ├── database/
│   │   ├── statefulset.yaml
│   │   ├── service.yaml
│   │   └── kustomization.yaml
│   └── kustomization.yaml
└── overlays/
    ├── dev/
    │   └── kustomization.yaml
    ├── staging/
    │   └── kustomization.yaml
    └── production/
        ├── kustomization.yaml
        ├── ingress.yaml
        ├── hpa.yaml
        └── resource-limits.yaml
```

**base/kustomization.yaml**
```yaml
resources:
  - frontend/
  - backend/
  - database/
```

**overlays/production/kustomization.yaml**
```yaml
bases:
  - ../../base

namespace: production

commonLabels:
  environment: production
  managed-by: kustomize

# Scale for production
replicas:
  - name: frontend
    count: 10
  - name: backend
    count: 5

# Production images
images:
  - name: frontend
    newName: gcr.io/mycompany/frontend
    newTag: v2.1.0
  - name: backend
    newName: gcr.io/mycompany/backend
    newTag: v2.1.0

# Production-only resources
resources:
  - ingress.yaml
  - hpa.yaml

# Add resource limits
patchesStrategicMerge:
  - resource-limits.yaml

# Production config
configMapGenerator:
  - name: app-config
    behavior: replace
    literals:
      - DATABASE_URL=prod-db.example.com
      - REDIS_URL=prod-redis.example.com
      - LOG_LEVEL=error
      - CACHE_ENABLED=true
```

**Deploy:**
```bash
kubectl apply -k overlays/production
```

---

## Summary: Why Kustomize is Awesome! 🌟

1. **No Duplication** - Write once, customize many times
2. **Pure YAML** - No templating language to learn
3. **Built-in** - Already in kubectl!
4. **Easy to Understand** - Clear what's different
5. **Version Control Friendly** - Easy to review changes
6. **Environment Management** - Dev, staging, prod made easy
7. **No Side Effects** - Original files unchanged
8. **Composable** - Mix and match bases and overlays

---

**Start using Kustomize today and make your Kubernetes life easier! 🚀**
