# Kubernetes Certificates Guide 📜
## Certificate Management & CSR

---

## What are Kubernetes Certificates? 🤔

**Certificates** = Identity cards for Kubernetes components and users

**Who needs certificates:**
- API Server
- Kubelet
- Controller Manager
- Scheduler
- ETCD
- Users (kubectl)

---

## Why Certificates? 💡

### Without Certificates:
```
Anyone can connect to API server ❌
No authentication ❌
No encryption ❌
```

### With Certificates:
```
Only trusted components can connect ✅
Mutual authentication ✅
Encrypted communication ✅
```

---

## Certificate Types 🎯

### 1. CA Certificate (Root)
**What:** Master certificate
**Signs:** All other certificates
**Location:** `/etc/kubernetes/pki/ca.crt`

### 2. API Server Certificate
**What:** API server identity
**Location:** `/etc/kubernetes/pki/apiserver.crt`

### 3. Kubelet Certificate
**What:** Node identity
**Location:** `/var/lib/kubelet/pki/kubelet.crt`

### 4. User Certificate
**What:** User identity
**Use:** kubectl authentication

---

## Creating User Certificate 🛠️

### Step 1: Generate Private Key

```bash
openssl genrsa -out john.key 2048
```

### Step 2: Create Certificate Signing Request (CSR)

```bash
openssl req -new -key john.key -out john.csr -subj "/CN=john/O=developers"
```

### Step 3: Create Kubernetes CSR

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: john
spec:
  request: <base64-encoded-csr>
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
```

```bash
# Encode CSR
cat john.csr | base64 | tr -d '\n'

# Apply CSR
kubectl apply -f john-csr.yaml
```

### Step 4: Approve CSR

```bash
# View CSR
kubectl get csr

# Approve CSR
kubectl certificate approve john

# Get certificate
kubectl get csr john -o jsonpath='{.status.certificate}' | base64 -d > john.crt
```

### Step 5: Create Kubeconfig

```bash
# Set cluster
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --server=https://api-server:6443 \
  --kubeconfig=john.kubeconfig

# Set credentials
kubectl config set-credentials john \
  --client-certificate=john.crt \
  --client-key=john.key \
  --kubeconfig=john.kubeconfig

# Set context
kubectl config set-context john@kubernetes \
  --cluster=kubernetes \
  --user=john \
  --kubeconfig=john.kubeconfig

# Use context
kubectl config use-context john@kubernetes --kubeconfig=john.kubeconfig
```

---

## Real-World Example 🌍

```yaml
# Complete user certificate setup
---
# 1. Generate key and CSR (bash)
# openssl genrsa -out alice.key 2048
# openssl req -new -key alice.key -out alice.csr -subj "/CN=alice/O=admins"

# 2. Create CSR in Kubernetes
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: alice
spec:
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0K...
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 31536000  # 1 year
  usages:
  - client auth
---
# 3. Role for alice
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: production
rules:
- apiGroups: ["", "apps"]
  resources: ["pods", "deployments", "services"]
  verbs: ["get", "list", "watch", "create", "update"]
---
# 4. RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: alice-developer
  namespace: production
subjects:
- kind: User
  name: alice
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

---

## Certificate Expiration ⏰

### Check Certificate Expiry

```bash
# Check all certificates
kubeadm certs check-expiration

# Check specific certificate
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -dates
```

### Renew Certificates

```bash
# Renew all certificates
kubeadm certs renew all

# Renew specific certificate
kubeadm certs renew apiserver

# Restart kubelet
systemctl restart kubelet
```

---

## Commands 🔧

```bash
# List CSRs
kubectl get csr

# Describe CSR
kubectl describe csr john

# Approve CSR
kubectl certificate approve john

# Deny CSR
kubectl certificate deny john

# Delete CSR
kubectl delete csr john

# Check certificate
openssl x509 -in cert.crt -text -noout
```

---

## Best Practices 📚

### 1. Use Short-Lived Certificates
```yaml
expirationSeconds: 86400  # 1 day
```

### 2. Rotate Certificates Regularly
```bash
# Before expiry!
kubeadm certs renew all
```

### 3. Use RBAC with Certificates
```yaml
# Give minimal permissions
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

### 4. Secure Private Keys
```bash
# Protect private keys
chmod 600 john.key
```

---

## Key Takeaways 🎯

1. **Certificates** = Identity in Kubernetes
2. **CSR** = Certificate Signing Request
3. **Approve** = Admin approves CSR
4. **Expire** = Certificates expire (renew!)
5. **RBAC** = Use with certificates for access control

**Certificates = Secure Identity! 📜**
