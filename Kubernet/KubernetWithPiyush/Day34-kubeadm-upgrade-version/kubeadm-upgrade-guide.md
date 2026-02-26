# Kubeadm Cluster Upgrade Guide ⬆️
## Safe Kubernetes Version Upgrade

---

## What is Cluster Upgrade? 🤔

**Cluster Upgrade** = Update Kubernetes to newer version

**Why Upgrade:**
- Security patches
- New features
- Bug fixes
- Stay supported

---

## Upgrade Strategy 🎯

```
Current: v1.27.0
Target: v1.28.0

1. Upgrade control plane
2. Upgrade worker nodes (one by one)
3. Verify everything works
```

---

## Pre-Upgrade Checklist ✅

```bash
# 1. Backup ETCD
ETCDCTL_API=3 etcdctl snapshot save backup.db

# 2. Check current version
kubectl version --short

# 3. Check node status
kubectl get nodes

# 4. Check pod status
kubectl get pods -A
```

---

## Upgrade Control Plane 🎛️

```bash
# 1. Find available versions
apt update
apt-cache madison kubeadm

# 2. Upgrade kubeadm
apt-mark unhold kubeadm
apt-get update && apt-get install -y kubeadm=1.28.0-00
apt-mark hold kubeadm

# 3. Verify kubeadm version
kubeadm version

# 4. Plan upgrade
kubeadm upgrade plan

# 5. Apply upgrade
kubeadm upgrade apply v1.28.0

# 6. Drain control plane
kubectl drain control-plane --ignore-daemonsets

# 7. Upgrade kubelet and kubectl
apt-mark unhold kubelet kubectl
apt-get update && apt-get install -y kubelet=1.28.0-00 kubectl=1.28.0-00
apt-mark hold kubelet kubectl

# 8. Restart kubelet
systemctl daemon-reload
systemctl restart kubelet

# 9. Uncordon control plane
kubectl uncordon control-plane

# 10. Verify
kubectl get nodes
```

---

## Upgrade Worker Nodes 👷

```bash
# On each worker node:

# 1. Drain node (from control plane)
kubectl drain worker-1 --ignore-daemonsets --delete-emptydir-data

# 2. SSH to worker node
ssh worker-1

# 3. Upgrade kubeadm
apt-mark unhold kubeadm
apt-get update && apt-get install -y kubeadm=1.28.0-00
apt-mark hold kubeadm

# 4. Upgrade node
kubeadm upgrade node

# 5. Upgrade kubelet and kubectl
apt-mark unhold kubelet kubectl
apt-get update && apt-get install -y kubelet=1.28.0-00 kubectl=1.28.0-00
apt-mark hold kubelet kubectl

# 6. Restart kubelet
systemctl daemon-reload
systemctl restart kubelet

# 7. Uncordon node (from control plane)
kubectl uncordon worker-1

# 8. Verify
kubectl get nodes
```

---

## Upgrade Order 📋

```
1. Control Plane Node 1
   ↓
2. Control Plane Node 2 (if HA)
   ↓
3. Control Plane Node 3 (if HA)
   ↓
4. Worker Node 1
   ↓
5. Worker Node 2
   ↓
6. Worker Node 3
```

---

## Version Skew Policy 📊

**Rules:**
- kube-apiserver: N
- kubelet: N-2 to N
- kubectl: N-1 to N+1

**Example:**
```
API Server: v1.28
Kubelet: v1.26, v1.27, v1.28 ✅
Kubectl: v1.27, v1.28, v1.29 ✅
```

---

## Rollback 🔙

```bash
# If upgrade fails, rollback

# 1. Restore ETCD backup
ETCDCTL_API=3 etcdctl snapshot restore backup.db

# 2. Downgrade kubeadm
apt-get install -y kubeadm=1.27.0-00

# 3. Apply downgrade
kubeadm upgrade apply v1.27.0

# 4. Downgrade kubelet
apt-get install -y kubelet=1.27.0-00

# 5. Restart kubelet
systemctl restart kubelet
```

---

## Best Practices 📚

### 1. Upgrade One Minor Version at a Time
```
v1.26 → v1.27 → v1.28 ✅
v1.26 → v1.28 ❌ (skip version)
```

### 2. Test in Non-Production First
```
Dev → Staging → Production
```

### 3. Backup Before Upgrade
```bash
# Always backup ETCD
etcdctl snapshot save backup.db
```

### 4. Upgrade During Maintenance Window
```
Low traffic period
Have rollback plan ready
```

---

## Key Takeaways 🎯

1. **Backup first** = ETCD snapshot
2. **Control plane first** = Then workers
3. **One at a time** = Don't rush
4. **Test first** = In non-prod
5. **Have rollback plan** = Just in case

**Cluster Upgrade = Careful Planning! ⬆️**
