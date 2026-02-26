# Private Docker Registry - Complete POC Guide 🚀
## Step-by-Step Implementation

---

## 📋 Prerequisites

- Kubernetes cluster running
- kubectl configured
- Docker installed
- Basic understanding of Kubernetes

---

## 🎯 What We'll Build

A secure private Docker registry in Kubernetes with:
- ✅ Persistent storage
- ✅ TLS encryption
- ✅ Basic authentication
- ✅ 2 replicas for HA

---

## 📁 Project Structure

```
Day42-private-docker-registry/
├── registry/
│   ├── auth/
│   │   └── htpasswd
│   └── certs/
│       ├── tls.crt
│       └── tls.key
├── volume.yml
├── deployment.yml
├── service.yml
└── STEP-BY-STEP-POC.md (this file)
```

---

## 🚀 Step-by-Step Implementation

### Step 1: Create Certificates 🔐

```bash
# Navigate to project directory
cd Day42-private-docker-registry

# Create certs directory if not exists
mkdir -p registry/certs

# Generate self-signed certificate
openssl req -newkey rsa:4096 -nodes -sha256 \
  -keyout registry/certs/tls.key \
  -x509 -days 365 \
  -out registry/certs/tls.crt \
  -subj "/CN=docker-registry/O=MyOrg"

# Verify certificates created
ls -la registry/certs/
# Should see: tls.crt and tls.key
```

**✅ Checkpoint:** You should have tls.crt and tls.key files

---

### Step 2: Create Authentication File 🔑

```bash
# Create auth directory if not exists
mkdir -p registry/auth

# Create htpasswd file with username and password
# Username: admin
# Password: password
docker run --rm --entrypoint htpasswd \
  httpd:2 -Bbn admin password > registry/auth/htpasswd

# Verify htpasswd created
cat registry/auth/htpasswd
# Should see encrypted password
```

**✅ Checkpoint:** You should have htpasswd file with encrypted password

---

### Step 3: Create Kubernetes Secrets 🔒

```bash
# Create secret for TLS certificates
kubectl create secret generic certs-secret \
  --from-file=tls.crt=registry/certs/tls.crt \
  --from-file=tls.key=registry/certs/tls.key

# Create secret for authentication
kubectl create secret generic auth-secret \
  --from-file=htpasswd=registry/auth/htpasswd

# Verify secrets created
kubectl get secrets
# Should see: certs-secret and auth-secret
```

**✅ Checkpoint:** Both secrets should be created

---

### Step 4: Fix Volume Configuration 📦

Your volume.yml has a typo. Let me fix it:

```bash
# Check current volume.yml
cat volume.yml
```

**Issue:** PVC name is `registry-pvc` but deployment uses `registory-pvc` (typo!)

**Fix:** Update deployment.yml:

```bash
# Edit deployment.yml
# Change: claimName: registory-pvc
# To: claimName: registry-pvc
```

Or apply this fixed version:

```yaml
# volume.yml (already correct)
apiVersion: v1
kind: PersistentVolume
metadata:
  name: registry-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: "chirag"
  hostPath:
    path: "/mnt/registry-data"  # Better path
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: registry-pvc
spec:
  storageClassName: "chirag"
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

---

### Step 5: Apply Volume Configuration 💾

```bash
# Create PV and PVC
kubectl apply -f volume.yml

# Verify
kubectl get pv
kubectl get pvc

# PVC should be Bound
# NAME           STATUS   VOLUME        CAPACITY
# registry-pvc   Bound    registry-pv   1Gi
```

**✅ Checkpoint:** PVC should show "Bound" status

---

### Step 6: Deploy Registry 🚀

```bash
# Apply deployment
kubectl apply -f deployment.yml

# Watch pods starting
kubectl get pods -w

# Wait for pods to be Running
# NAME                        READY   STATUS    RESTARTS   AGE
# registry-xxxxxxxxxx-xxxxx   1/1     Running   0          30s
# registry-xxxxxxxxxx-xxxxx   1/1     Running   0          30s
```

**✅ Checkpoint:** 2 registry pods should be Running

---

### Step 7: Create Service 🌐

```bash
# Apply service
kubectl apply -f service.yml

# Verify service
kubectl get svc docker-registry

# Get service details
kubectl describe svc docker-registry
```

**✅ Checkpoint:** Service should be created with port 5000

---

### Step 8: Test Registry Access 🧪

```bash
# Port forward to access registry
kubectl port-forward svc/docker-registry 5000:5000

# In another terminal, test registry
curl -k https://localhost:5000/v2/_catalog

# Should return: {"repositories":[]}
```

**✅ Checkpoint:** Registry should respond with empty catalog

---

### Step 9: Login to Registry 🔐

```bash
# Login with credentials
# Username: admin
# Password: password
docker login localhost:5000 -u admin -p password

# Should see: Login Succeeded
```

**✅ Checkpoint:** Login should succeed

---

### Step 10: Push Image to Registry 📤

```bash
# Pull a test image
docker pull nginx:alpine

# Tag for private registry
docker tag nginx:alpine localhost:5000/nginx:alpine

# Push to private registry
docker push localhost:5000/nginx:alpine

# Verify image in registry
curl -k -u admin:password https://localhost:5000/v2/_catalog

# Should return: {"repositories":["nginx"]}
```

**✅ Checkpoint:** Image should be in registry

---

### Step 11: Pull Image from Registry 📥

```bash
# Remove local image
docker rmi localhost:5000/nginx:alpine
docker rmi nginx:alpine

# Pull from private registry
docker pull localhost:5000/nginx:alpine

# Verify
docker images | grep nginx
```

**✅ Checkpoint:** Image should be pulled successfully

---

### Step 12: Use in Kubernetes Pod 🎪

Create a test pod using private registry:

```bash
# Create secret for pod to access registry
kubectl create secret docker-registry regcred \
  --docker-server=docker-registry:5000 \
  --docker-username=admin \
  --docker-password=password

# Create test pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-private-registry
spec:
  containers:
  - name: nginx
    image: docker-registry:5000/nginx:alpine
  imagePullSecrets:
  - name: regcred
EOF

# Check pod status
kubectl get pod test-private-registry

# Should be Running
```

**✅ Checkpoint:** Pod should pull image from private registry

---

## 🎉 POC Complete!

You now have:
- ✅ Private Docker registry running in Kubernetes
- ✅ TLS encryption enabled
- ✅ Basic authentication configured
- ✅ Persistent storage for images
- ✅ 2 replicas for high availability
- ✅ Successfully pushed and pulled images
- ✅ Kubernetes pods using private registry

---

## 📝 Quick Commands Reference

```bash
# Check all resources
kubectl get all -l app=registry

# Check registry logs
kubectl logs -l app=registry

# Check registry storage
kubectl exec -it <registry-pod> -- ls -la /var/lib/registry

# List images in registry
curl -k -u admin:password https://localhost:5000/v2/_catalog

# List tags for an image
curl -k -u admin:password https://localhost:5000/v2/nginx/tags/list

# Delete pod to test HA
kubectl delete pod <registry-pod-name>
# Another pod should still serve requests

# Scale registry
kubectl scale deployment registry --replicas=3

# Clean up
kubectl delete -f deployment.yml
kubectl delete -f service.yml
kubectl delete -f volume.yml
kubectl delete secret certs-secret auth-secret regcred
```

---

## 🔧 Troubleshooting

### Issue 1: PVC not binding
```bash
# Check PV and PVC
kubectl describe pv registry-pv
kubectl describe pvc registry-pvc

# Check if path exists on node
ssh <node> "ls -la /mnt/registry-data"
```

### Issue 2: Pods not starting
```bash
# Check pod logs
kubectl logs <registry-pod>

# Check pod events
kubectl describe pod <registry-pod>

# Common issues:
# - Secrets not found
# - PVC not bound
# - Image pull errors
```

### Issue 3: Can't login to registry
```bash
# Check if port-forward is running
# Check username/password in htpasswd
cat registry/auth/htpasswd

# Recreate auth secret
kubectl delete secret auth-secret
kubectl create secret generic auth-secret \
  --from-file=htpasswd=registry/auth/htpasswd
```

### Issue 4: TLS certificate errors
```bash
# For testing, use -k flag with curl
curl -k https://localhost:5000/v2/_catalog

# Or add certificate to Docker
sudo mkdir -p /etc/docker/certs.d/localhost:5000
sudo cp registry/certs/tls.crt /etc/docker/certs.d/localhost:5000/ca.crt
sudo systemctl restart docker
```

---

## 🎓 What You Learned

1. ✅ How to create TLS certificates
2. ✅ How to create htpasswd authentication
3. ✅ How to use Kubernetes Secrets
4. ✅ How to configure persistent storage
5. ✅ How to deploy Docker registry in Kubernetes
6. ✅ How to push/pull images to private registry
7. ✅ How to use imagePullSecrets in pods
8. ✅ How to troubleshoot registry issues

---

## 🚀 Next Steps

1. **Add Ingress** - Expose registry externally
2. **Add Monitoring** - Monitor registry metrics
3. **Backup Strategy** - Backup registry data
4. **High Availability** - Add more replicas
5. **Storage Class** - Use cloud storage (AWS EBS, GCP PD)

---

**Congratulations bhai! Your Private Docker Registry POC is complete! 🎉**

**You can now:**
- Store private images
- Control access
- Use in production
- Scale as needed

**POC Status: ✅ COMPLETED**
