# Multi-Stage Deployment with Kustomize 🚀
## Complete CI/CD Pipeline Guide

---

## What is Multi-Stage Deployment? 🎯

**Multi-Stage Deployment** means deploying your application through multiple environments before reaching production.

**The Journey:**
```
Code → Dev → QA/Test → Staging → Production
```

Each stage has:
- Different configurations
- Different resource limits
- Different replicas
- Different secrets/configs
- Different monitoring levels

---

## Why Multi-Stage? 💡

### Without Multi-Stage (Dangerous! ⚠️):
```bash
Developer writes code
    ↓
Deploy directly to Production  ❌ RISKY!
    ↓
Bug in production = Customers affected! 😱
```

### With Multi-Stage (Safe! ✅):
```bash
Developer writes code
    ↓
Deploy to Dev (test basic functionality)
    ↓
Deploy to QA (automated tests)
    ↓
Deploy to Staging (exact copy of production)
    ↓
Deploy to Production (confident it works!)
```

---

## Benefits of Multi-Stage Deployment 🌟

| Benefit | Description |
|---------|-------------|
| **Catch Bugs Early** | Find issues in dev/staging, not production |
| **Safe Testing** | Test new features without affecting users |
| **Gradual Rollout** | Deploy to small environments first |
| **Easy Rollback** | If staging fails, production is safe |
| **Team Collaboration** | Devs use dev, QA uses test, ops use staging |
| **Cost Effective** | Small resources in dev, full resources in prod |
| **Compliance** | Meet regulatory requirements for testing |

---

## Complete Multi-Stage Setup 🏗️

### Directory Structure:

```
my-app/
├── base/                           # Common configuration
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── hpa.yaml
│   └── kustomization.yaml
│
├── overlays/
│   ├── dev/                        # Development (1 replica, debug logs)
│   │   ├── kustomization.yaml
│   │   ├── configmap-patch.yaml
│   │   └── resource-patch.yaml
│   │
│   ├── qa/                         # QA/Testing (2 replicas, test data)
│   │   ├── kustomization.yaml
│   │   ├── configmap-patch.yaml
│   │   └── resource-patch.yaml
│   │
│   ├── staging/                    # Staging (5 replicas, prod-like)
│   │   ├── kustomization.yaml
│   │   ├── configmap-patch.yaml
│   │   ├── resource-patch.yaml
│   │   └── ingress.yaml
│   │
│   └── production/                 # Production (10 replicas, full resources)
│       ├── kustomization.yaml
│       ├── configmap-patch.yaml
│       ├── resource-patch.yaml
│       ├── ingress.yaml
│       ├── hpa-patch.yaml
│       └── monitoring.yaml
│
└── README.md
```

---

## Stage 1: Base Configuration (Common for All) 📦

**base/deployment.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 1                    # Will be overridden per stage
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
        image: myapp:latest      # Will be overridden per stage
        ports:
        - containerPort: 8080
        env:
        - name: APP_ENV
          value: "base"          # Will be overridden
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database_url
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
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

**base/configmap.yaml**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "localhost:5432"
  log_level: "info"
  cache_enabled: "false"
```

**base/kustomization.yaml**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml
  - configmap.yaml
```

---

## Stage 2: Development Environment 🔧

**Purpose:** Quick testing, frequent deployments, debug mode

**overlays/dev/kustomization.yaml**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# Use base configuration
bases:
  - ../../base

# Dev namespace
namespace: dev

# Add dev labels
commonLabels:
  environment: dev
  stage: development

# Add dev prefix
namePrefix: dev-

# Only 1 replica (save resources)
replicas:
  - name: webapp
    count: 1

# Use dev image tag
images:
  - name: myapp
    newTag: dev-latest

# Dev-specific ConfigMap
configMapGenerator:
  - name: app-config
    behavior: replace
    literals:
      - database_url=dev-db.internal:5432
      - log_level=debug                    # Debug logs in dev!
      - cache_enabled=false
      - feature_new_ui=true                # Enable all features
      - feature_beta_api=true
      - debug_mode=true

# Minimal resources (save money!)
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
            resources:
              limits:
                cpu: "200m"
                memory: "256Mi"
              requests:
                cpu: "100m"
                memory: "128Mi"
```

**Deploy to Dev:**
```bash
kubectl apply -k overlays/dev

# Result:
# - Name: dev-webapp
# - Namespace: dev
# - Replicas: 1
# - Resources: Minimal
# - Logs: Debug level
# - All features enabled
```

---

## Stage 3: QA/Testing Environment 🧪

**Purpose:** Automated testing, QA team testing, integration tests

**overlays/qa/kustomization.yaml**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

namespace: qa

commonLabels:
  environment: qa
  stage: testing

namePrefix: qa-

# 2 replicas for load testing
replicas:
  - name: webapp
    count: 2

# Use QA image tag (tested build)
images:
  - name: myapp
    newTag: qa-v1.2.3

# QA-specific ConfigMap
configMapGenerator:
  - name: app-config
    behavior: replace
    literals:
      - database_url=qa-db.internal:5432
      - log_level=info
      - cache_enabled=true
      - feature_new_ui=true            # Test new features
      - feature_beta_api=false         # Not ready yet
      - test_mode=true                 # Enable test mode
      - mock_payment=true              # Use mock payment gateway

# Medium resources
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
            resources:
              limits:
                cpu: "500m"
                memory: "512Mi"
              requests:
                cpu: "250m"
                memory: "256Mi"
```

**Deploy to QA:**
```bash
kubectl apply -k overlays/qa

# Result:
# - Name: qa-webapp
# - Namespace: qa
# - Replicas: 2
# - Resources: Medium
# - Test mode enabled
# - Mock services enabled
```

---

## Stage 4: Staging Environment 🎭

**Purpose:** Production replica, final testing before prod, performance testing

**overlays/staging/kustomization.yaml**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

namespace: staging

commonLabels:
  environment: staging
  stage: pre-production

namePrefix: staging-

# Same as production (5 replicas)
replicas:
  - name: webapp
    count: 5

# Use release candidate image
images:
  - name: myapp
    newTag: rc-v1.2.3

# Staging-specific ConfigMap (production-like)
configMapGenerator:
  - name: app-config
    behavior: replace
    literals:
      - database_url=staging-db.example.com:5432
      - log_level=warn                     # Production-like logging
      - cache_enabled=true
      - feature_new_ui=true                # Only stable features
      - feature_beta_api=false
      - cdn_url=https://cdn-staging.example.com
      - api_url=https://api-staging.example.com

# Production-like resources
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
            resources:
              limits:
                cpu: "1000m"
                memory: "1Gi"
              requests:
                cpu: "500m"
                memory: "512Mi"

# Add ingress (production-like)
resources:
  - ingress.yaml
```

**overlays/staging/ingress.yaml**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-staging
spec:
  rules:
  - host: staging.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: webapp-service
            port:
              number: 80
  tls:
  - hosts:
    - staging.example.com
    secretName: staging-tls
```

**Deploy to Staging:**
```bash
kubectl apply -k overlays/staging

# Result:
# - Name: staging-webapp
# - Namespace: staging
# - Replicas: 5 (same as prod!)
# - Resources: Production-like
# - Ingress: staging.example.com
# - Exact copy of production setup
```

---

## Stage 5: Production Environment 🚀

**Purpose:** Live environment, serving real users, maximum reliability

**overlays/production/kustomization.yaml**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

namespace: production

commonLabels:
  environment: production
  stage: live

namePrefix: prod-

# High availability (10 replicas)
replicas:
  - name: webapp
    count: 10

# Use stable production image
images:
  - name: myapp
    newTag: v1.2.3

# Production ConfigMap
configMapGenerator:
  - name: app-config
    behavior: replace
    literals:
      - database_url=prod-db.example.com:5432
      - log_level=error                    # Only errors in prod
      - cache_enabled=true
      - feature_new_ui=true                # Only stable features
      - cdn_url=https://cdn.example.com
      - api_url=https://api.example.com
      - monitoring_enabled=true
      - alerting_enabled=true

# Maximum resources
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
            resources:
              limits:
                cpu: "2000m"
                memory: "2Gi"
              requests:
                cpu: "1000m"
                memory: "1Gi"

# Production resources
resources:
  - ingress.yaml
  - hpa.yaml
  - monitoring.yaml
```

**overlays/production/ingress.yaml**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  rules:
  - host: www.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: webapp-service
            port:
              number: 80
  tls:
  - hosts:
    - www.example.com
    secretName: prod-tls
```

**overlays/production/hpa.yaml**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: webapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 10
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

**Deploy to Production:**
```bash
kubectl apply -k overlays/production

# Result:
# - Name: prod-webapp
# - Namespace: production
# - Replicas: 10 (auto-scales to 50)
# - Resources: Maximum
# - Ingress: www.example.com
# - HPA enabled
# - Monitoring enabled
```

---

## Comparison Table: All Stages 📊

| Feature | Dev | QA | Staging | Production |
|---------|-----|-----|---------|------------|
| **Replicas** | 1 | 2 | 5 | 10-50 |
| **CPU Limit** | 200m | 500m | 1000m | 2000m |
| **Memory Limit** | 256Mi | 512Mi | 1Gi | 2Gi |
| **Log Level** | debug | info | warn | error |
| **Cache** | disabled | enabled | enabled | enabled |
| **Features** | all | testing | stable | stable |
| **Ingress** | no | no | yes | yes |
| **HPA** | no | no | no | yes |
| **Monitoring** | basic | basic | full | full |
| **Cost** | $10/month | $50/month | $200/month | $1000/month |

---

## CI/CD Pipeline Integration 🔄

### GitLab CI/CD Example:

**.gitlab-ci.yml**
```yaml
stages:
  - build
  - deploy-dev
  - deploy-qa
  - deploy-staging
  - deploy-production

variables:
  IMAGE_NAME: myregistry.com/myapp

# Build Docker image
build:
  stage: build
  script:
    - docker build -t $IMAGE_NAME:$CI_COMMIT_SHA .
    - docker push $IMAGE_NAME:$CI_COMMIT_SHA

# Deploy to Dev (automatic on every commit)
deploy-dev:
  stage: deploy-dev
  script:
    - cd overlays/dev
    - kustomize edit set image myapp=$IMAGE_NAME:$CI_COMMIT_SHA
    - kubectl apply -k .
  only:
    - branches

# Deploy to QA (automatic on merge to main)
deploy-qa:
  stage: deploy-qa
  script:
    - cd overlays/qa
    - kustomize edit set image myapp=$IMAGE_NAME:$CI_COMMIT_SHA
    - kubectl apply -k .
  only:
    - main

# Deploy to Staging (manual approval)
deploy-staging:
  stage: deploy-staging
  script:
    - cd overlays/staging
    - kustomize edit set image myapp=$IMAGE_NAME:$CI_COMMIT_SHA
    - kubectl apply -k .
  when: manual
  only:
    - main

# Deploy to Production (manual approval + confirmation)
deploy-production:
  stage: deploy-production
  script:
    - cd overlays/production
    - kustomize edit set image myapp=$IMAGE_NAME:$CI_COMMIT_SHA
    - kubectl apply -k .
  when: manual
  only:
    - tags
  environment:
    name: production
    url: https://www.example.com
```

### GitHub Actions Example:

**.github/workflows/deploy.yml**
```yaml
name: Multi-Stage Deployment

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  # Deploy to Dev
  deploy-dev:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to Dev
        run: |
          kubectl apply -k overlays/dev

  # Deploy to QA (after dev succeeds)
  deploy-qa:
    needs: deploy-dev
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to QA
        run: |
          kubectl apply -k overlays/qa

  # Deploy to Staging (manual approval)
  deploy-staging:
    needs: deploy-qa
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to Staging
        run: |
          kubectl apply -k overlays/staging

  # Deploy to Production (manual approval)
  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to Production
        run: |
          kubectl apply -k overlays/production
```

---

## Deployment Workflow 🔄

### Step-by-Step Process:

```
1. Developer commits code
   ↓
2. CI builds Docker image
   ↓
3. Auto-deploy to DEV
   ↓ (if tests pass)
4. Auto-deploy to QA
   ↓ (QA team approves)
5. Manual deploy to STAGING
   ↓ (smoke tests pass)
6. Manual deploy to PRODUCTION
   ↓
7. Monitor and celebrate! 🎉
```

### Commands for Each Stage:

```bash
# 1. Deploy to Dev (automatic)
kubectl apply -k overlays/dev

# 2. Test in Dev
curl http://dev.example.com/health

# 3. Deploy to QA (automatic)
kubectl apply -k overlays/qa

# 4. Run automated tests
./run-tests.sh qa

# 5. Deploy to Staging (manual)
kubectl apply -k overlays/staging

# 6. Smoke test staging
./smoke-test.sh staging

# 7. Deploy to Production (manual + approval)
kubectl apply -k overlays/production

# 8. Monitor production
kubectl get pods -n production -w
```

---

## Rollback Strategy 🔙

### Quick Rollback Commands:

```bash
# Rollback Dev
kubectl rollout undo deployment/dev-webapp -n dev

# Rollback QA
kubectl rollout undo deployment/qa-webapp -n qa

# Rollback Staging
kubectl rollout undo deployment/staging-webapp -n staging

# Rollback Production (CRITICAL!)
kubectl rollout undo deployment/prod-webapp -n production

# Check rollback status
kubectl rollout status deployment/prod-webapp -n production
```

### Rollback to Specific Version:

```bash
# See deployment history
kubectl rollout history deployment/prod-webapp -n production

# Rollback to specific revision
kubectl rollout undo deployment/prod-webapp -n production --to-revision=3
```

---

## Best Practices 📚

### 1. Always Test in Lower Environments First
```bash
# ✅ Good
Dev → QA → Staging → Production

# ❌ Bad
Dev → Production (skipping stages!)
```

### 2. Use Image Tags, Not 'latest'
```yaml
# ✅ Good
images:
  - name: myapp
    newTag: v1.2.3

# ❌ Bad
images:
  - name: myapp
    newTag: latest
```

### 3. Keep Staging Identical to Production
```yaml
# Staging should have:
# - Same replicas
# - Same resources
# - Same configuration
# Only difference: different data/domain
```

### 4. Automate Lower Environments, Manual for Production
```yaml
# Auto-deploy: Dev, QA
# Manual deploy: Staging, Production
```

### 5. Monitor Each Stage
```bash
# Add monitoring to all stages
# - Dev: Basic logs
# - QA: Test results
# - Staging: Full monitoring
# - Production: Full monitoring + alerting
```

---

## Troubleshooting Multi-Stage 🔍

### Issue 1: Different behavior in staging vs production
```bash
# Check differences
diff overlays/staging/kustomization.yaml overlays/production/kustomization.yaml

# Make staging identical to production
# Only change: namespace and domain
```

### Issue 2: Forgot which stage is deployed
```bash
# Check all stages
kubectl get deployments -A | grep webapp

# Check image tags
kubectl get deployment -n production prod-webapp -o jsonpath='{.spec.template.spec.containers[0].image}'
```

### Issue 3: Need to test production config in staging
```bash
# Copy production kustomization to staging
cp overlays/production/kustomization.yaml overlays/staging/

# Change only namespace
sed -i 's/production/staging/g' overlays/staging/kustomization.yaml
```

---

## Summary: Why Multi-Stage is Essential 🌟

| Without Multi-Stage | With Multi-Stage |
|---------------------|------------------|
| ❌ Deploy bugs to production | ✅ Catch bugs in dev/qa |
| ❌ No testing before prod | ✅ Test in multiple stages |
| ❌ Risky deployments | ✅ Safe, gradual rollout |
| ❌ Hard to rollback | ✅ Easy rollback per stage |
| ❌ One environment = one config | ✅ Optimized per stage |
| ❌ Expensive (all resources always) | ✅ Cost-effective (scale per need) |

---

**Multi-stage deployment with Kustomize = Safe, reliable, professional deployments! 🚀**
