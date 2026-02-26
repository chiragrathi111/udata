# Kubeconfig Complete Guide ⚙️
## Multi-Cluster Configuration

---

## What is Kubeconfig? 🤔

**Kubeconfig** = Configuration file for kubectl to connect to clusters

**Location:** `~/.kube/config`

**Contains:**
- Clusters (API server addresses)
- Users (credentials)
- Contexts (cluster + user + namespace)

---

## Why Use Kubeconfig? 💡

### Without Kubeconfig:
```bash
# Every command needs full details
kubectl get pods \
  --server=https://cluster1:6443 \
  --certificate-authority=ca.crt \
  --client-certificate=user.crt \
  --client-key=user.key
❌ Too long!
```

### With Kubeconfig:
```bash
# Simple command
kubectl get pods
✅ Easy!
```

---

## Kubeconfig Structure 📋

```yaml
apiVersion: v1
kind: Config
clusters:
- name: dev-cluster
  cluster:
    server: https://dev-api:6443
    certificate-authority: /path/to/ca.crt
- name: prod-cluster
  cluster:
    server: https://prod-api:6443
    certificate-authority: /path/to/ca.crt

users:
- name: dev-user
  user:
    client-certificate: /path/to/dev-user.crt
    client-key: /path/to/dev-user.key
- name: prod-user
  user:
    client-certificate: /path/to/prod-user.crt
    client-key: /path/to/prod-user.key

contexts:
- name: dev
  context:
    cluster: dev-cluster
    user: dev-user
    namespace: development
- name: prod
  context:
    cluster: prod-cluster
    user: prod-user
    namespace: production

current-context: dev
```

---

## Managing Contexts 🔧

```bash
# View current context
kubectl config current-context

# List all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context prod

# Set namespace for context
kubectl config set-context --current --namespace=production

# View config
kubectl config view

# View specific cluster
kubectl config view --minify
```

---

## Creating Kubeconfig 🛠️

### Method 1: Manual

```bash
# Set cluster
kubectl config set-cluster dev-cluster \
  --server=https://dev-api:6443 \
  --certificate-authority=ca.crt

# Set user
kubectl config set-credentials dev-user \
  --client-certificate=user.crt \
  --client-key=user.key

# Set context
kubectl config set-context dev \
  --cluster=dev-cluster \
  --user=dev-user \
  --namespace=development

# Use context
kubectl config use-context dev
```

### Method 2: From File

```bash
# Merge kubeconfig
export KUBECONFIG=~/.kube/config:~/new-cluster.yaml
kubectl config view --flatten > ~/.kube/config
```

---

## Real-World Example 🌍

```yaml
# Multi-cluster setup
apiVersion: v1
kind: Config
clusters:
- name: dev-cluster
  cluster:
    server: https://dev.example.com:6443
    certificate-authority-data: LS0tLS1CRUdJTi...
- name: staging-cluster
  cluster:
    server: https://staging.example.com:6443
    certificate-authority-data: LS0tLS1CRUdJTi...
- name: prod-cluster
  cluster:
    server: https://prod.example.com:6443
    certificate-authority-data: LS0tLS1CRUdJTi...

users:
- name: developer
  user:
    client-certificate-data: LS0tLS1CRUdJTi...
    client-key-data: LS0tLS1CRUdJTi...
- name: admin
  user:
    client-certificate-data: LS0tLS1CRUdJTi...
    client-key-data: LS0tLS1CRUdJTi...

contexts:
- name: dev
  context:
    cluster: dev-cluster
    user: developer
    namespace: dev
- name: staging
  context:
    cluster: staging-cluster
    user: developer
    namespace: staging
- name: prod
  context:
    cluster: prod-cluster
    user: admin
    namespace: production

current-context: dev
```

**Usage:**
```bash
# Work in dev
kubectl config use-context dev
kubectl get pods

# Switch to staging
kubectl config use-context staging
kubectl get pods

# Switch to prod (admin access)
kubectl config use-context prod
kubectl get pods
```

---

## Multiple Kubeconfig Files 📁

```bash
# Set multiple kubeconfig files
export KUBECONFIG=~/.kube/config:~/.kube/dev-config:~/.kube/prod-config

# View merged config
kubectl config view

# Flatten into one file
kubectl config view --flatten > ~/.kube/merged-config
```

---

## Commands 🔧

```bash
# View config
kubectl config view

# Get current context
kubectl config current-context

# List contexts
kubectl config get-contexts

# Switch context
kubectl config use-context prod

# Set cluster
kubectl config set-cluster my-cluster --server=https://api:6443

# Set user
kubectl config set-credentials my-user --token=abc123

# Set context
kubectl config set-context my-context --cluster=my-cluster --user=my-user

# Delete context
kubectl config delete-context old-context

# Rename context
kubectl config rename-context old-name new-name

# Set namespace
kubectl config set-context --current --namespace=production
```

---

## Best Practices 📚

### 1. Use Descriptive Names
```yaml
# ✅ Good
contexts:
- name: prod-us-east
- name: prod-eu-west
- name: dev-local

# ❌ Bad
contexts:
- name: context1
- name: context2
```

### 2. Set Default Namespace
```bash
kubectl config set-context --current --namespace=production
```

### 3. Backup Kubeconfig
```bash
cp ~/.kube/config ~/.kube/config.backup
```

### 4. Use KUBECONFIG Environment Variable
```bash
export KUBECONFIG=~/.kube/prod-config
```

---

## Troubleshooting 🔍

### Issue 1: Can't connect to cluster
```bash
# Check current context
kubectl config current-context

# Check server address
kubectl config view --minify

# Test connection
kubectl cluster-info
```

### Issue 2: Wrong namespace
```bash
# Check current namespace
kubectl config view --minify | grep namespace

# Set namespace
kubectl config set-context --current --namespace=production
```

### Issue 3: Certificate errors
```bash
# Check certificate
kubectl config view --raw

# Verify certificate
openssl x509 -in <cert-file> -text -noout
```

---

## Key Takeaways 🎯

1. **Kubeconfig** = kubectl configuration
2. **Context** = cluster + user + namespace
3. **Switch** = Easy cluster switching
4. **Multiple** = Manage many clusters
5. **Backup** = Always backup config

**Kubeconfig = Multi-Cluster Management! ⚙️**
