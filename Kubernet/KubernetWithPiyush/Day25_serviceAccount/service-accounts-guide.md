# Service Accounts Complete Guide 🤖
## Pod Identity & Authentication

---

## What is Service Account? 🤔

**Service Account** = Identity for pods to access Kubernetes API

**Think of it like:**
- User Account = For humans (you)
- Service Account = For pods (applications)

---

## Why Use Service Accounts? 💡

### Without Service Account:
```
Pod wants to list other pods ❌
No authentication ❌
API server rejects ❌
```

### With Service Account:
```
Pod uses Service Account ✅
API server authenticates ✅
Pod can list pods ✅
```

---

## Default Service Account 📦

Every namespace has a `default` service account:

```bash
kubectl get serviceaccount
# NAME      SECRETS   AGE
# default   1         10d
```

**Every pod automatically uses it!**

---

## Creating Service Account 🛠️

### Method 1: YAML

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  namespace: default
```

### Method 2: Command

```bash
kubectl create serviceaccount my-service-account
```

---

## Using Service Account 📝

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: my-service-account
  containers:
  - name: app
    image: nginx
```

---

## Service Account with RBAC 🔐

```yaml
# 1. Service Account
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-reader
  namespace: default
---
# 2. Role (permissions)
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader-role
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
---
# 3. RoleBinding (connect SA to Role)
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: pod-reader
  namespace: default
roleRef:
  kind: Role
  name: pod-reader-role
  apiGroup: rbac.authorization.k8s.io
---
# 4. Pod using Service Account
apiVersion: v1
kind: Pod
metadata:
  name: pod-reader-pod
spec:
  serviceAccountName: pod-reader
  containers:
  - name: app
    image: nginx
```

---

## Real-World Example: CI/CD Pipeline 🚀

```yaml
# Service Account for Jenkins
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: ci-cd
---
# ClusterRole (cluster-wide permissions)
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins-deployer
rules:
- apiGroups: ["", "apps"]
  resources: ["pods", "deployments", "services"]
  verbs: ["get", "list", "create", "update", "delete"]
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get", "list"]
---
# ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins-deployer-binding
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: ci-cd
roleRef:
  kind: ClusterRole
  name: jenkins-deployer
  apiGroup: rbac.authorization.k8s.io
---
# Jenkins Pod
apiVersion: v1
kind: Pod
metadata:
  name: jenkins
  namespace: ci-cd
spec:
  serviceAccountName: jenkins
  containers:
  - name: jenkins
    image: jenkins/jenkins:lts
    ports:
    - containerPort: 8080
```

**What Jenkins can do:**
- Deploy applications
- Create/update deployments
- Manage services
- List namespaces

---

## Accessing API from Pod 🔌

```bash
# Inside pod
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
APISERVER=https://kubernetes.default.svc

# List pods
curl --cacert $CACERT --header "Authorization: Bearer $TOKEN" \
  $APISERVER/api/v1/namespaces/default/pods
```

---

## Commands 🔧

```bash
# Create service account
kubectl create serviceaccount my-sa

# Get service accounts
kubectl get serviceaccount
kubectl get sa

# Describe service account
kubectl describe sa my-sa

# Delete service account
kubectl delete sa my-sa

# Get token (Kubernetes 1.24+)
kubectl create token my-sa

# Get token (older versions)
kubectl get secret $(kubectl get sa my-sa -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 -d
```

---

## Service Account Token 🎫

### Kubernetes 1.24+
**Tokens are time-bound (not stored in secrets)**

```bash
# Create token (expires in 1 hour)
kubectl create token my-sa

# Create token with custom expiry
kubectl create token my-sa --duration=24h
```

### Before Kubernetes 1.24
**Tokens stored in secrets (never expire)**

```bash
# Get token from secret
kubectl get secret my-sa-token-xxxxx -o jsonpath='{.data.token}' | base64 -d
```

---

## Best Practices 📚

### 1. Use Specific Service Accounts
```yaml
# ✅ Good
serviceAccountName: app-specific-sa

# ❌ Bad
serviceAccountName: default
```

### 2. Principle of Least Privilege
```yaml
# ✅ Good - Only what's needed
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]

# ❌ Bad - Too much access
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
```

### 3. Disable Auto-Mount (if not needed)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  automountServiceAccountToken: false
  containers:
  - name: app
    image: nginx
```

### 4. Use Namespaced Roles
```yaml
# ✅ Good - Namespace-specific
kind: Role

# ❌ Bad - Cluster-wide (unless needed)
kind: ClusterRole
```

---

## Troubleshooting 🔍

### Issue 1: Permission denied
```bash
# Check service account
kubectl get sa

# Check role binding
kubectl get rolebinding

# Describe role
kubectl describe role my-role
```

### Issue 2: Token not found
```bash
# Kubernetes 1.24+
kubectl create token my-sa

# Check if service account exists
kubectl get sa my-sa
```

---

## Key Takeaways 🎯

1. **Service Account** = Pod identity
2. **Default** = Every namespace has one
3. **RBAC** = Control permissions
4. **Token** = Auto-mounted in pod
5. **Use specific** = Don't use default

**Service Accounts = Pod Authentication! 🤖**
