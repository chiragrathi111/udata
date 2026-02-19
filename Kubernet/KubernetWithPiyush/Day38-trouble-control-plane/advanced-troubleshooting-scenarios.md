# Advanced Kubernetes Troubleshooting Scenarios 🚀
## Real-Time Production Issues & Solutions

---

## Scenario 1: ETCD Database Issues (Critical!)
**Problem:** Cluster state data lost or corrupted, kubectl commands hanging

**NOTE:** ETCD is the brain of Kubernetes - stores all cluster data (pods, services, secrets, etc.)

### Symptoms:
```bash
kubectl get nodes
# Hangs or shows: "The connection to the server was refused"
```

### Troubleshooting Steps:

```bash
# Step 1: Check if ETCD pod is running
kubectl get pods -n kube-system | grep etcd
# OR on control plane node
crictl ps | grep etcd

# Step 2: Check ETCD logs
crictl logs <etcd-container-id>
# OR
tail -f /var/log/pods/kube-system_etcd-*/*/*.log

# Step 3: Check ETCD health directly
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health

# Step 4: Check ETCD member list
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  member list
```

### Common Fixes:

**Fix 1: ETCD manifest file corrupted**
```bash
# Check ETCD static pod manifest
cat /etc/kubernetes/manifests/etcd.yaml

# Look for typos in:
# - Volume mounts
# - Certificate paths
# - Listen URLs

# If corrupted, restore from backup or fix manually
sudo vi /etc/kubernetes/manifests/etcd.yaml
# Kubelet will auto-restart ETCD pod
```

**Fix 2: Disk space full (Common in production!)**
```bash
# Check disk space on control plane
df -h

# ETCD needs space in /var/lib/etcd
du -sh /var/lib/etcd

# If full, clean up or expand disk
# NOTE: Never delete /var/lib/etcd manually! Use ETCD backup/restore
```

**Fix 3: Restore from backup**
```bash
# Stop API server first
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/

# Restore ETCD snapshot
ETCDCTL_API=3 etcdctl snapshot restore /backup/etcd-snapshot.db \
  --data-dir=/var/lib/etcd-restore

# Update ETCD manifest to use new data-dir
sudo vi /etc/kubernetes/manifests/etcd.yaml
# Change: --data-dir=/var/lib/etcd-restore

# Start API server back
sudo mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
```

---

## Scenario 2: Certificate Expiration (Production Nightmare!)
**Problem:** Cluster suddenly stops working, "x509: certificate has expired"

**NOTE:** Kubernetes certificates expire after 1 year by default!

### Symptoms:
```bash
kubectl get nodes
# Error: Unable to connect to the server: x509: certificate has expired or is not yet valid
```

### Troubleshooting Steps:

```bash
# Step 1: Check all certificate expiration dates
sudo kubeadm certs check-expiration

# Output shows:
# CERTIFICATE                EXPIRES                  RESIDUAL TIME
# admin.conf                 Dec 25, 2024 10:30 UTC   364d
# apiserver                  Dec 25, 2024 10:30 UTC   364d
```

### Solution:

```bash
# Renew all certificates (Run on control plane)
sudo kubeadm certs renew all

# Restart control plane components
sudo systemctl restart kubelet

# Update kubeconfig
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Verify
kubectl get nodes
```

**PRO TIP:** Set up monitoring to alert 30 days before expiration!

---

## Scenario 3: Scheduler Not Scheduling Pods
**Problem:** Pods stuck in "Pending" state forever

**NOTE:** kube-scheduler assigns pods to nodes based on resources

### Symptoms:
```bash
kubectl get pods
# NAME          READY   STATUS    RESTARTS   AGE
# my-app-pod    0/1     Pending   0          5m
```

### Troubleshooting Steps:

```bash
# Step 1: Check why pod is pending
kubectl describe pod my-app-pod
# Look at "Events" section at bottom

# Common reasons in Events:
# - "0/3 nodes are available: insufficient cpu"
# - "0/3 nodes are available: node(s) had taint"
# - "no nodes available to schedule pods"
```

**Case 1: Insufficient Resources**
```bash
# Check node resources
kubectl describe nodes | grep -A 5 "Allocated resources"

# See what's using resources
kubectl top nodes
kubectl top pods --all-namespaces

# Solution: Either add more nodes or reduce pod requests
kubectl edit deployment my-app
# Reduce: resources.requests.cpu and resources.requests.memory
```

**Case 2: Scheduler Pod Down**
```bash
# Check scheduler status
kubectl get pods -n kube-system | grep scheduler

# If not running, check logs
kubectl logs -n kube-system kube-scheduler-<node-name>

# Check scheduler manifest
cat /etc/kubernetes/manifests/kube-scheduler.yaml

# Common issue: Wrong API server address
# Fix in manifest file and kubelet will restart it
```

**Case 3: Node Taints**
```bash
# Check node taints
kubectl describe node <node-name> | grep Taints

# Remove taint if needed
kubectl taint nodes <node-name> key=value:NoSchedule-

# Or add toleration to pod
# In pod spec:
# tolerations:
# - key: "key"
#   operator: "Equal"
#   value: "value"
#   effect: "NoSchedule"
```

---

## Scenario 4: Network Plugin (CNI) Failure
**Problem:** Pods can't communicate, DNS not working

**NOTE:** CNI (Container Network Interface) provides networking to pods

### Symptoms:
```bash
# Pods running but can't ping each other
kubectl exec -it pod1 -- ping <pod2-ip>
# Network unreachable

# CoreDNS pods in CrashLoopBackOff
kubectl get pods -n kube-system | grep coredns
```

### Troubleshooting Steps:

```bash
# Step 1: Check CNI pods (Calico/Flannel/Weave)
kubectl get pods -n kube-system | grep -E 'calico|flannel|weave'

# Step 2: Check CNI configuration
ls -l /etc/cni/net.d/
cat /etc/cni/net.d/*.conf

# Step 3: Check if CNI binaries exist
ls -l /opt/cni/bin/
```

### Solutions:

**Fix 1: Reinstall CNI plugin**
```bash
# For Calico example:
kubectl delete -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Wait for pods to be ready
kubectl get pods -n kube-system -w
```

**Fix 2: Check IP forwarding (Common issue!)**
```bash
# IP forwarding must be enabled
cat /proc/sys/net/ipv4/ip_forward
# Should show: 1

# If shows 0, enable it:
sudo sysctl -w net.ipv4.ip_forward=1
sudo echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
```

**Fix 3: CoreDNS troubleshooting**
```bash
# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# Common issue: Loop detected
# Edit CoreDNS configmap
kubectl edit configmap coredns -n kube-system
# Remove "loop" plugin or fix forward configuration

# Restart CoreDNS
kubectl rollout restart deployment coredns -n kube-system
```

---

## Scenario 5: Node NotReady Status
**Problem:** Node shows "NotReady", pods evicted

**NOTE:** Kubelet reports node status to API server every 10 seconds

### Symptoms:
```bash
kubectl get nodes
# NAME     STATUS     ROLES    AGE   VERSION
# node-1   NotReady   worker   5d    v1.28.0
```

### Troubleshooting Steps:

```bash
# Step 1: Check node details
kubectl describe node node-1
# Look at "Conditions" section

# Common conditions:
# - DiskPressure: True (disk full)
# - MemoryPressure: True (memory full)
# - PIDPressure: True (too many processes)
# - Ready: False (kubelet not healthy)
```

**Fix 1: Kubelet not running**
```bash
# SSH to the node
ssh user@node-1

# Check kubelet status
sudo systemctl status kubelet

# If stopped, start it
sudo systemctl start kubelet
sudo systemctl enable kubelet

# Check kubelet logs
sudo journalctl -u kubelet -f

# Common errors:
# - "failed to load Kubelet config file" - Fix config at /var/lib/kubelet/config.yaml
# - "certificate has expired" - Renew certificates
```

**Fix 2: Disk pressure**
```bash
# Check disk usage on node
df -h

# Clean up:
# 1. Docker/containerd images
sudo crictl rmi --prune

# 2. Old logs
sudo journalctl --vacuum-time=3d

# 3. Unused containers
sudo crictl rm $(sudo crictl ps -a -q --state=exited)

# 4. Check pod logs taking space
du -sh /var/log/pods/* | sort -h
```

**Fix 3: Memory pressure**
```bash
# Check memory on node
free -h

# Find memory hogs
ps aux --sort=-%mem | head -10

# Check pod memory usage
kubectl top pods --all-namespaces --sort-by=memory

# Solution: Add memory limits to pods or add more nodes
```

---

## Scenario 6: ImagePullBackOff / ErrImagePull
**Problem:** Pod can't pull container image

**NOTE:** Very common in production with private registries!

### Symptoms:
```bash
kubectl get pods
# NAME      READY   STATUS             RESTARTS   AGE
# my-pod    0/1     ImagePullBackOff   0          2m
```

### Troubleshooting Steps:

```bash
# Step 1: Get detailed error
kubectl describe pod my-pod
# Look at Events section

# Common errors:
# - "Failed to pull image: unauthorized"
# - "Failed to pull image: not found"
# - "Failed to pull image: timeout"
```

**Fix 1: Image doesn't exist**
```bash
# Verify image name and tag
kubectl get pod my-pod -o yaml | grep image:

# Common mistakes:
# - Wrong image name
# - Wrong tag (latest vs v1.0)
# - Typo in registry URL

# Fix: Update deployment with correct image
kubectl set image deployment/my-app container-name=correct-image:tag
```

**Fix 2: Private registry authentication**
```bash
# Create docker registry secret
kubectl create secret docker-registry my-registry-secret \
  --docker-server=myregistry.com \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=myemail@example.com

# Add to pod spec or service account
kubectl patch serviceaccount default \
  -p '{"imagePullSecrets": [{"name": "my-registry-secret"}]}'

# Or in deployment YAML:
# spec:
#   imagePullSecrets:
#   - name: my-registry-secret
```

**Fix 3: Network/DNS issues**
```bash
# Test if node can reach registry
ssh user@node-1
curl -v https://myregistry.com

# Check DNS resolution
nslookup myregistry.com

# Check proxy settings (if behind corporate proxy)
cat /etc/systemd/system/containerd.service.d/http-proxy.conf

# Add proxy if needed:
sudo mkdir -p /etc/systemd/system/containerd.service.d/
sudo vi /etc/systemd/system/containerd.service.d/http-proxy.conf
# [Service]
# Environment="HTTP_PROXY=http://proxy:8080"
# Environment="HTTPS_PROXY=http://proxy:8080"
# Environment="NO_PROXY=localhost,127.0.0.1"

sudo systemctl daemon-reload
sudo systemctl restart containerd
```

---

## Scenario 7: PersistentVolume Issues
**Problem:** Pod can't mount storage, stuck in "ContainerCreating"

**NOTE:** Storage issues are tricky - involves PV, PVC, and StorageClass

### Symptoms:
```bash
kubectl get pods
# NAME      READY   STATUS              RESTARTS   AGE
# db-pod    0/1     ContainerCreating   0          5m

kubectl describe pod db-pod
# Events: "Unable to attach or mount volumes"
```

### Troubleshooting Steps:

```bash
# Step 1: Check PVC status
kubectl get pvc
# NAME      STATUS    VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS
# my-pvc    Pending   -         -          -              standard

# Step 2: Describe PVC for errors
kubectl describe pvc my-pvc

# Step 3: Check PV
kubectl get pv

# Step 4: Check StorageClass
kubectl get storageclass
```

**Fix 1: No StorageClass**
```bash
# List available storage classes
kubectl get sc

# If none, create one (example for local storage)
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF

# Update PVC to use this StorageClass
kubectl edit pvc my-pvc
# Add: storageClassName: local-storage
```

**Fix 2: PV not available**
```bash
# Create PersistentVolume manually
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data
  storageClassName: local-storage
EOF

# PVC should now bind to PV
kubectl get pvc
```

**Fix 3: Node selector mismatch**
```bash
# Check if PV has node affinity
kubectl get pv my-pv -o yaml | grep -A 10 nodeAffinity

# Check if pod is scheduled on correct node
kubectl get pod db-pod -o wide

# If mismatch, either:
# 1. Update PV node affinity
# 2. Or add node selector to pod to match PV
```

---

## Scenario 8: Service Not Accessible
**Problem:** Can't access application through Service

**NOTE:** Service provides stable IP/DNS for pods

### Symptoms:
```bash
# Service exists but can't connect
kubectl get svc
# NAME      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
# my-svc    ClusterIP   10.96.100.50    <none>        80/TCP

curl http://10.96.100.50
# Connection refused or timeout
```

### Troubleshooting Steps:

```bash
# Step 1: Check if service has endpoints
kubectl get endpoints my-svc
# Should show pod IPs

# If no endpoints, service selector doesn't match pod labels!

# Step 2: Verify service selector
kubectl get svc my-svc -o yaml | grep -A 5 selector

# Step 3: Verify pod labels
kubectl get pods --show-labels

# Step 4: Test pod directly
kubectl get pods -o wide
curl http://<pod-ip>:8080
```

**Fix 1: Label mismatch**
```bash
# Service selector: app=frontend
# Pod labels: app=front-end (wrong!)

# Fix pod labels
kubectl label pod my-pod app=frontend --overwrite

# Or fix service selector
kubectl edit svc my-svc
# Update selector to match pod labels
```

**Fix 2: Wrong port configuration**
```bash
# Check service ports
kubectl get svc my-svc -o yaml

# Service spec:
#   ports:
#   - port: 80          # Service port (what you connect to)
#     targetPort: 8080  # Pod port (where app listens)

# Make sure targetPort matches container port
kubectl get pod my-pod -o yaml | grep containerPort
```

**Fix 3: kube-proxy issues**
```bash
# kube-proxy manages service networking
kubectl get pods -n kube-system | grep kube-proxy

# Check kube-proxy logs
kubectl logs -n kube-system kube-proxy-xxxxx

# Check iptables rules (on node)
sudo iptables-save | grep my-svc

# Restart kube-proxy if needed
kubectl delete pod -n kube-system -l k8s-app=kube-proxy
```

---

## Scenario 9: High Restart Count (CrashLoopBackOff)
**Problem:** Pod keeps restarting, never becomes stable

**NOTE:** Application crashes immediately after starting

### Symptoms:
```bash
kubectl get pods
# NAME      READY   STATUS             RESTARTS   AGE
# my-pod    0/1     CrashLoopBackOff   10         5m
```

### Troubleshooting Steps:

```bash
# Step 1: Check pod logs
kubectl logs my-pod
kubectl logs my-pod --previous  # Logs from previous crash

# Step 2: Check pod events
kubectl describe pod my-pod

# Step 3: Check liveness/readiness probes
kubectl get pod my-pod -o yaml | grep -A 10 livenessProbe
```

**Fix 1: Application error**
```bash
# Common application issues:
# - Missing environment variables
# - Can't connect to database
# - Configuration file missing

# Check environment variables
kubectl exec my-pod -- env

# Check mounted config
kubectl exec my-pod -- ls -la /etc/config

# Fix: Add missing env vars or configmaps
kubectl set env deployment/my-app DATABASE_URL=postgres://db:5432
```

**Fix 2: Probe misconfiguration**
```bash
# Liveness probe killing healthy pod!
# Example: App takes 60s to start, but probe starts at 10s

# Fix: Increase initialDelaySeconds
kubectl edit deployment my-app

# Update:
# livenessProbe:
#   httpGet:
#     path: /health
#     port: 8080
#   initialDelaySeconds: 90  # Increased from 10
#   periodSeconds: 10
#   timeoutSeconds: 5
#   failureThreshold: 3
```

**Fix 3: Resource limits too low**
```bash
# Pod killed by OOMKiller (Out Of Memory)
kubectl describe pod my-pod | grep -i oom

# Check resource limits
kubectl get pod my-pod -o yaml | grep -A 5 resources

# Increase memory limit
kubectl set resources deployment my-app \
  --limits=memory=512Mi \
  --requests=memory=256Mi
```

---

## Scenario 10: Namespace Stuck in Terminating
**Problem:** Can't delete namespace, stuck forever

**NOTE:** Usually due to finalizers or resources not cleaning up

### Symptoms:
```bash
kubectl delete namespace old-namespace
# namespace "old-namespace" deleted

kubectl get namespaces
# NAME              STATUS        AGE
# old-namespace     Terminating   10m
```

### Solution:

```bash
# Step 1: Check what's blocking
kubectl get all -n old-namespace
kubectl api-resources --verbs=list --namespaced -o name | \
  xargs -n 1 kubectl get --show-kind --ignore-not-found -n old-namespace

# Step 2: Force delete by removing finalizers
kubectl get namespace old-namespace -o json > temp.json

# Edit temp.json and remove "finalizers" section
# Change from:
# "spec": {
#   "finalizers": ["kubernetes"]
# }
# To:
# "spec": {
#   "finalizers": []
# }

# Apply the change
kubectl replace --raw "/api/v1/namespaces/old-namespace/finalize" \
  -f ./temp.json

# Namespace should now delete
```

---

## Pro Tips for Troubleshooting 🎯

### 1. Always check these first:
```bash
# The "Big 4" control plane components
kubectl get pods -n kube-system | grep -E 'apiserver|scheduler|controller|etcd'
```

### 2. Enable verbose logging:
```bash
kubectl get pods -v=8  # Shows API calls
kubectl describe pod my-pod -v=9  # Maximum verbosity
```

### 3. Quick health check script:
```bash
#!/bin/bash
echo "=== Nodes ==="
kubectl get nodes

echo "=== Control Plane ==="
kubectl get pods -n kube-system

echo "=== Component Status ==="
kubectl get cs

echo "=== Top Resource Usage ==="
kubectl top nodes
kubectl top pods -A --sort-by=memory | head -10
```

### 4. Monitor logs in real-time:
```bash
# Follow logs from multiple pods
kubectl logs -f -l app=myapp --all-containers=true

# Stern tool (better than kubectl logs)
stern myapp --namespace production
```

### 5. Create debugging pod:
```bash
# Pod with networking tools
kubectl run debug-pod --image=nicolaka/netshoot -it --rm -- /bin/bash

# Inside pod, test connectivity
ping 8.8.8.8
nslookup kubernetes.default
curl http://my-service
```

---

## Common Production Patterns 📚

### Pattern 1: Rolling Update Failure
```bash
# Deployment stuck in rolling update
kubectl rollout status deployment/my-app

# Check rollout history
kubectl rollout history deployment/my-app

# Rollback to previous version
kubectl rollout undo deployment/my-app

# Rollback to specific revision
kubectl rollout undo deployment/my-app --to-revision=2
```

### Pattern 2: Resource Quota Exceeded
```bash
# Check namespace quotas
kubectl get resourcequota -n my-namespace
kubectl describe resourcequota -n my-namespace

# Check current usage
kubectl describe namespace my-namespace

# Increase quota if needed
kubectl edit resourcequota my-quota -n my-namespace
```

### Pattern 3: Cluster Upgrade Issues
```bash
# Before upgrade, drain nodes properly
kubectl drain node-1 --ignore-daemonsets --delete-emptydir-data

# After upgrade, uncordon
kubectl uncordon node-1

# Check version skew
kubectl get nodes -o wide
kubectl version --short
```

---

## Emergency Commands (Save Your Day!) 🚨

```bash
# 1. Force delete stuck pod
kubectl delete pod my-pod --grace-period=0 --force

# 2. Get all events sorted by time
kubectl get events --sort-by='.lastTimestamp' -A

# 3. Find pods using most CPU
kubectl top pods -A --sort-by=cpu

# 4. Check which pods are on which nodes
kubectl get pods -A -o wide --sort-by=.spec.nodeName

# 5. Get all container images in cluster
kubectl get pods -A -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | sort -u

# 6. Restart all pods in deployment (without downtime)
kubectl rollout restart deployment/my-app

# 7. Check API server response time
time kubectl get nodes

# 8. Export all resources in namespace
kubectl get all -n my-namespace -o yaml > backup.yaml
```

---

## Remember: The Troubleshooting Mindset 🧠

1. **Don't Panic** - Read error messages carefully
2. **Check Logs** - Logs tell you 90% of the story
3. **Describe Everything** - kubectl describe is your best friend
4. **Work Layer by Layer** - Start from control plane → nodes → pods → containers
5. **Google is OK** - Even pros Google error messages!
6. **Practice** - Break things in test environment to learn

---

**Keep this file handy! You'll become a Kubernetes master! 💪**
