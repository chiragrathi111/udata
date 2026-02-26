# Helm Complete Guide ⎈
## Kubernetes Package Manager

---

## What is Helm? 🤔

**Helm** = Package manager for Kubernetes (like apt/yum for Linux)

**Think of it like:**
- App Store for Kubernetes
- Install complex apps with one command
- Manage versions easily

---

## Why Use Helm? 💡

### Without Helm:
```
Install MySQL:
- Create ConfigMap
- Create Secret
- Create PVC
- Create Deployment
- Create Service
= 5 YAML files, 100+ lines ❌
```

### With Helm:
```
helm install mysql bitnami/mysql
= 1 command ✅
```

---

## Key Concepts 🎯

### 1. Chart
**What:** Package of Kubernetes resources
**Like:** .deb or .rpm package

### 2. Release
**What:** Instance of a chart running in cluster
**Like:** Installed application

### 3. Repository
**What:** Collection of charts
**Like:** App store

---

## Installing Helm 🛠️

```bash
# Download and install
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify
helm version
```

---

## Basic Commands 🔧

```bash
# Add repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repositories
helm repo update

# Search charts
helm search repo mysql

# Install chart
helm install my-mysql bitnami/mysql

# List releases
helm list

# Upgrade release
helm upgrade my-mysql bitnami/mysql

# Rollback release
helm rollback my-mysql 1

# Uninstall release
helm uninstall my-mysql

# Get values
helm show values bitnami/mysql
```

---

## Installing Applications 📦

### Example 1: MySQL

```bash
# Install MySQL
helm install my-mysql bitnami/mysql \
  --set auth.rootPassword=password123

# Get connection info
helm status my-mysql

# Connect to MySQL
kubectl run mysql-client --rm -it --image=mysql:8.0 -- \
  mysql -h my-mysql -p
```

### Example 2: Nginx with Custom Values

```bash
# Create values file
cat > values.yaml <<EOF
replicaCount: 3
service:
  type: LoadBalancer
  port: 80
resources:
  limits:
    cpu: 500m
    memory: 512Mi
EOF

# Install with custom values
helm install my-nginx bitnami/nginx -f values.yaml
```

### Example 3: WordPress

```bash
# Install WordPress
helm install my-wordpress bitnami/wordpress \
  --set wordpressUsername=admin \
  --set wordpressPassword=password \
  --set mariadb.auth.rootPassword=secretpassword

# Get WordPress URL
kubectl get svc my-wordpress
```

---

## Creating Your Own Chart 📝

```bash
# Create chart
helm create myapp

# Chart structure:
myapp/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── templates/          # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
└── charts/             # Dependencies
```

### Chart.yaml

```yaml
apiVersion: v2
name: myapp
description: My Application
version: 1.0.0
appVersion: "1.0"
```

### values.yaml

```yaml
replicaCount: 2
image:
  repository: myapp
  tag: "latest"
service:
  type: ClusterIP
  port: 80
```

### templates/deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: 80
```

---

## Helm Repositories 🏪

```bash
# Add official charts
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami

# Add custom repo
helm repo add myrepo https://mycompany.com/charts

# List repos
helm repo list

# Remove repo
helm repo remove stable

# Update repos
helm repo update
```

---

## Managing Releases 🔄

```bash
# List all releases
helm list

# List in all namespaces
helm list -A

# Get release status
helm status my-release

# Get release history
helm history my-release

# Upgrade release
helm upgrade my-release bitnami/nginx

# Rollback to previous version
helm rollback my-release

# Rollback to specific revision
helm rollback my-release 2

# Uninstall release
helm uninstall my-release

# Uninstall but keep history
helm uninstall my-release --keep-history
```

---

## Helm Values 📊

```bash
# Show default values
helm show values bitnami/mysql

# Install with custom values
helm install my-mysql bitnami/mysql \
  --set auth.rootPassword=password \
  --set primary.persistence.size=20Gi

# Install with values file
helm install my-mysql bitnami/mysql -f custom-values.yaml

# Override multiple values
helm install my-mysql bitnami/mysql \
  --set auth.rootPassword=pass1 \
  --set auth.database=mydb \
  --set primary.persistence.enabled=true
```

---

## Best Practices 📚

### 1. Use Values Files
```bash
# ✅ Good
helm install myapp ./chart -f values.yaml

# ❌ Bad (too many --set)
helm install myapp ./chart --set a=1 --set b=2 --set c=3...
```

### 2. Version Your Charts
```yaml
# Chart.yaml
version: 1.2.3
```

### 3. Use Namespaces
```bash
helm install myapp ./chart -n production
```

### 4. Test Before Install
```bash
# Dry run
helm install myapp ./chart --dry-run --debug

# Template only
helm template myapp ./chart
```

---

## Troubleshooting 🔍

```bash
# Debug installation
helm install myapp ./chart --dry-run --debug

# Get manifest
helm get manifest my-release

# Get values
helm get values my-release

# Check history
helm history my-release

# Rollback if issues
helm rollback my-release
```

---

## Key Takeaways 🎯

1. **Helm** = Kubernetes package manager
2. **Chart** = Package of resources
3. **Release** = Installed instance
4. **One command** = Install complex apps
5. **Easy upgrades** = Version management

**Helm = Easy Application Management! ⎈**
