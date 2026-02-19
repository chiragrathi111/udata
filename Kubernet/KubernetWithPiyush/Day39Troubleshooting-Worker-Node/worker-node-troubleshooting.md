# Worker Node Troubleshooting Guide 🛠️
## Real-Time Production Scenarios & Solutions

---

## Scenario 1: Node Status "NotReady"
**Problem:** Worker node shows NotReady, pods getting evicted

**NOTE:** NotReady means kubelet can't communicate with control plane or node has issues!

### Symptoms:
```bash
kubectl get nodes
# NAME          STATUS     ROLES    AGE   VERSION
# worker-1      NotReady   <none>   5d    v1.28.0
# worker-2      Ready      <none>   5d    v1.28.0

kubectl get pods -o wide
# Pods on worker-1 showing "Terminating" or "Unknown"
```

### Troubleshooting Steps:

```bash
# Step 1: Check node details
kubectl describe node worker-1
# Look at "Conditions" section:
# - Ready: False
# - DiskPressure: True/False
# - MemoryPressure: True/False
# - PIDPressure: True/False

# Step 2: SSH to the worker node
ssh user@worker-1

# Step 3: Check kubelet status
sudo systemctl status kubelet
# Active: inactive (dead)  ❌ Problem!
# Active: active (running) ✅ Good
```

**Fix 1: Kubelet service stopped**
```bash
# SSH to worker node
ssh user@worker-1

# Check kubelet status
sudo systemctl status kubelet

# If stopped, start it
sudo systemctl start kubelet
sudo systemctl enable kubelet

# Check logs for errors
sudo journalctl -u kubelet -f

# Common errors you'll see:
# - "failed to load Kubelet config file"
# - "unable to register node"
# - "certificate has expired"
```

**Fix 2: Kubelet configuration issue**
```bash
# Check kubelet config file
sudo cat /var/lib/kubelet/config.yaml

# Check kubelet service file
sudo cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# If config corrupted, restore from backup or control plane
scp control-plane:/var/lib/kubelet/config.yaml /tmp/
sudo cp /tmp/config.yaml /var/lib/kubelet/config.yaml

# Restart kubelet
sudo systemctl restart kubelet
```

**Fix 3: Network connectivity to control plane**
```bash
# Test connection to API server
curl -k https://<control-plane-ip>:6443

# Check if port 6443 is reachable
telnet <control-plane-ip> 6443

# Check firewall rules
sudo iptables -L -n | grep 6443

# If firewall blocking, allow it
sudo iptables -A INPUT -p tcp --dport 6443 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 6443 -j ACCEPT

# Or disable firewall temporarily (testing only!)
sudo systemctl stop firewalld
sudo systemctl stop ufw
```

---

## Scenario 2: Disk Pressure on Node
**Problem:** Node running out of disk space, pods evicted

**NOTE:** Kubernetes evicts pods when disk usage > 85% (default threshold)

### Symptoms:
```bash
kubectl describe node worker-1
# Conditions:
#   DiskPressure    True    KubeletHasDiskPressure

kubectl get events | grep worker-1
# Evicted pod due to disk pressure
```

### Troubleshooting Steps:

```bash
# Step 1: Check disk usage
ssh user@worker-1
df -h
# /dev/sda1    50G   48G   2G   96%  /        ❌ Critical!

# Step 2: Find what's using space
du -sh /* | sort -h
du -sh /var/* | sort -h

# Step 3: Check container logs size
du -sh /var/log/pods/* | sort -h | tail -20
du -sh /var/log/containers/* | sort -h | tail -20
```

**Fix 1: Clean up container images**
```bash
# List all images
sudo crictl images

# Remove unused images
sudo crictl rmi --prune

# Or manually remove specific images
sudo crictl rmi <image-id>

# Check space freed
df -h
```

**Fix 2: Clean up old logs**
```bash
# Check log sizes
du -sh /var/log/pods/*
du -sh /var/log/containers/*

# Clean old journal logs
sudo journalctl --vacuum-time=3d
sudo journalctl --vacuum-size=500M

# Rotate logs
sudo logrotate -f /etc/logrotate.conf

# Clean old pod logs (be careful!)
sudo find /var/log/pods/ -type f -mtime +7 -delete
```

**Fix 3: Remove stopped containers**
```bash
# List all containers (including stopped)
sudo crictl ps -a

# Remove exited containers
sudo crictl rm $(sudo crictl ps -a -q --state=exited)

# Clean up containerd
sudo crictl rmi --prune
```

**Fix 4: Expand disk (permanent solution)**
```bash
# For cloud VMs (AWS/GCP/Azure)
# 1. Expand volume from cloud console
# 2. Resize partition on node

# Check current size
lsblk

# Resize partition (example for ext4)
sudo growpart /dev/sda 1
sudo resize2fs /dev/sda1

# Verify
df -h
```

---

## Scenario 3: Memory Pressure on Node
**Problem:** Node running out of memory, pods killed by OOM

**NOTE:** When memory full, kernel kills processes - usually your pods!

### Symptoms:
```bash
kubectl describe node worker-1
# Conditions:
#   MemoryPressure    True    KubeletHasInsufficientMemory

kubectl get pods -o wide | grep worker-1
# Pods showing OOMKilled or Evicted
```

### Troubleshooting Steps:

```bash
# Step 1: Check memory usage
ssh user@worker-1
free -h
#               total   used    free
# Mem:          8.0Gi   7.8Gi   200Mi   ❌ Almost full!

# Step 2: Find memory hogs
top -o %MEM
# Or
ps aux --sort=-%mem | head -20

# Step 3: Check pod memory usage
kubectl top pods --all-namespaces | sort -k4 -h
```

**Fix 1: Identify and fix memory leaks**
```bash
# Check which pods using most memory
kubectl top pods -A --sort-by=memory

# Check pod memory limits
kubectl get pod <pod-name> -o yaml | grep -A 5 resources

# Describe pod to see OOM kills
kubectl describe pod <pod-name> | grep -i oom

# Fix: Add or increase memory limits
kubectl set resources deployment <name> \
  --limits=memory=1Gi \
  --requests=memory=512Mi
```

**Fix 2: Drain and add more memory**
```bash
# Drain node (move pods to other nodes)
kubectl drain worker-1 --ignore-daemonsets --delete-emptydir-data

# Add more RAM to the node (cloud console or physical)

# Uncordon node
kubectl uncordon worker-1
```

---

## Scenario 4: Kubelet Certificate Expired
**Problem:** Node can't authenticate with control plane

**NOTE:** Kubelet certificates expire after 1 year by default!

### Symptoms:
```bash
kubectl get nodes
# NAME       STATUS     ROLES    AGE   VERSION
# worker-1   NotReady   <none>   400d  v1.28.0

ssh user@worker-1
sudo journalctl -u kubelet | grep certificate
# Error: x509: certificate has expired
```

### Troubleshooting Steps:

```bash
# Step 1: Check certificate expiration
ssh user@worker-1
sudo openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -dates
# notAfter=Dec 25 2023 10:30:00 GMT  ❌ Expired!

# Step 2: Check kubelet logs
sudo journalctl -u kubelet -n 50 | grep -i cert
```

**Fix 1: Renew kubelet certificate**
```bash
# On worker node
ssh user@worker-1

# Stop kubelet
sudo systemctl stop kubelet

# Backup old certificates
sudo cp -r /var/lib/kubelet/pki /var/lib/kubelet/pki.backup

# Remove old certificates
sudo rm /var/lib/kubelet/pki/kubelet-client*

# Start kubelet (will auto-generate new cert)
sudo systemctl start kubelet

# Check if certificate renewed
sudo openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -dates

# Verify node is Ready
kubectl get nodes
```

**Fix 2: Manual certificate approval (if auto-approval disabled)**
```bash
# Check pending CSRs
kubectl get csr
# NAME        AGE   SIGNERNAME                      REQUESTOR   CONDITION
# csr-xxxxx   1m    kubernetes.io/kubelet-serving   worker-1    Pending

# Approve the CSR
kubectl certificate approve csr-xxxxx

# Verify node is Ready
kubectl get nodes
```

---

## Scenario 5: Container Runtime (containerd/docker) Issues
**Problem:** Containers can't start on node

**NOTE:** Kubelet uses container runtime (containerd/docker) to run pods!

### Symptoms:
```bash
kubectl get pods -o wide | grep worker-1
# NAME            STATUS              NODE
# webapp-abc123   ContainerCreating   worker-1

kubectl describe pod webapp-abc123
# Events: Failed to create pod sandbox
```

### Troubleshooting Steps:

```bash
# Step 1: Check container runtime status
ssh user@worker-1
sudo systemctl status containerd
# Or for docker
sudo systemctl status docker

# Step 2: Check runtime logs
sudo journalctl -u containerd -f

# Step 3: Test runtime directly
sudo crictl ps
sudo crictl images
```

**Fix 1: Container runtime stopped**
```bash
# Start containerd
sudo systemctl start containerd
sudo systemctl enable containerd

# Or for docker
sudo systemctl start docker
sudo systemctl enable docker

# Restart kubelet
sudo systemctl restart kubelet

# Verify
sudo crictl ps
```

**Fix 2: Runtime configuration corrupted**
```bash
# Check containerd config
sudo cat /etc/containerd/config.toml

# If corrupted, regenerate default config
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd
sudo systemctl restart kubelet
```

**Fix 3: Runtime socket issue**
```bash
# Check if socket exists
ls -l /run/containerd/containerd.sock

# If missing, restart containerd
sudo systemctl restart containerd

# Update kubelet to use correct socket
sudo vi /var/lib/kubelet/kubeadm-flags.env
# Add: --container-runtime-endpoint=unix:///run/containerd/containerd.sock

sudo systemctl restart kubelet
```

---

## Scenario 6: Network Plugin (CNI) Not Working on Node
**Problem:** Pods on node can't get IP addresses

**NOTE:** CNI plugin assigns IPs to pods - without it, pods stuck in ContainerCreating!

### Symptoms:
```bash
kubectl get pods -o wide | grep worker-1
# NAME            STATUS              IP
# webapp-abc123   ContainerCreating   <none>

kubectl describe pod webapp-abc123
# Events: Failed to create pod sandbox: NetworkPlugin cni failed
```

### Troubleshooting Steps:

```bash
# Step 1: Check CNI binaries exist
ssh user@worker-1
ls -l /opt/cni/bin/
# Should see: bridge, flannel, calico, etc.

# Step 2: Check CNI configuration
ls -l /etc/cni/net.d/
cat /etc/cni/net.d/*.conf

# Step 3: Check CNI pod logs (if using DaemonSet)
kubectl logs -n kube-system <cni-pod-on-worker-1>
```

**Fix 1: CNI binaries missing**
```bash
# Download CNI plugins
wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz

# Extract to /opt/cni/bin
sudo mkdir -p /opt/cni/bin
sudo tar -xzf cni-plugins-linux-amd64-v1.3.0.tgz -C /opt/cni/bin/

# Verify
ls -l /opt/cni/bin/

# Restart kubelet
sudo systemctl restart kubelet
```

**Fix 2: CNI configuration missing**
```bash
# Copy CNI config from working node
scp worker-2:/etc/cni/net.d/10-flannel.conflist /tmp/
sudo cp /tmp/10-flannel.conflist /etc/cni/net.d/

# Or reinstall CNI plugin (example: Calico)
kubectl delete pod -n kube-system <calico-pod-on-worker-1>
# DaemonSet will recreate it

# Restart kubelet
sudo systemctl restart kubelet
```

**Fix 3: IP forwarding disabled**
```bash
# Check IP forwarding
cat /proc/sys/net/ipv4/ip_forward
# Should be: 1

# If 0, enable it
sudo sysctl -w net.ipv4.ip_forward=1
sudo echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Also enable bridge netfilter
sudo modprobe br_netfilter
sudo sysctl -w net.bridge.bridge-nf-call-iptables=1

# Make permanent
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system
```

---

## Scenario 7: Too Many Pods on Node (PID Pressure)
**Problem:** Node can't create more processes

**NOTE:** Each container creates processes - too many pods = too many PIDs!

### Symptoms:
```bash
kubectl describe node worker-1
# Conditions:
#   PIDPressure    True    KubeletHasPIDPressure

kubectl get pods -o wide | grep worker-1
# Many pods stuck in ContainerCreating
```

### Troubleshooting Steps:

```bash
# Step 1: Check PID usage
ssh user@worker-1
ps aux | wc -l
# 32000  ❌ Too many!

# Step 2: Check PID limit
cat /proc/sys/kernel/pid_max
# 32768

# Step 3: Find which pods have most processes
for pod in $(sudo crictl pods -q); do
  echo "Pod: $pod"
  sudo crictl exec $pod ps aux | wc -l
done | sort -k2 -n
```

**Fix 1: Increase PID limit**
```bash
# Increase system PID limit
sudo sysctl -w kernel.pid_max=65536

# Make permanent
echo "kernel.pid_max=65536" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Restart kubelet
sudo systemctl restart kubelet
```

**Fix 2: Reduce pods on node**
```bash
# Drain some pods to other nodes
kubectl drain worker-1 --ignore-daemonsets --delete-emptydir-data --pod-selector='app=non-critical'

# Or scale down deployments
kubectl scale deployment <name> --replicas=2

# Uncordon when ready
kubectl uncordon worker-1
```

---

## Scenario 8: Node Taints Preventing Pod Scheduling
**Problem:** Pods not scheduling on node even though it's Ready

**NOTE:** Taints repel pods - only pods with matching tolerations can schedule!

### Symptoms:
```bash
kubectl get nodes
# NAME       STATUS   ROLES    AGE   VERSION
# worker-1   Ready    <none>   5d    v1.28.0

kubectl get pods
# NAME            STATUS    AGE
# webapp-abc123   Pending   5m

kubectl describe pod webapp-abc123
# Events: 0/3 nodes available: 1 node(s) had taint {key=value:NoSchedule}
```

### Troubleshooting Steps:

```bash
# Step 1: Check node taints
kubectl describe node worker-1 | grep Taints
# Taints: maintenance=true:NoSchedule

# Step 2: List all node taints
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

**Fix 1: Remove taint**
```bash
# Remove specific taint
kubectl taint nodes worker-1 maintenance=true:NoSchedule-
# Note the minus (-) at the end!

# Remove all taints
kubectl taint nodes worker-1 maintenance-

# Verify
kubectl describe node worker-1 | grep Taints
# Taints: <none>
```

**Fix 2: Add toleration to pod**
```bash
# Edit deployment to add toleration
kubectl edit deployment webapp

# Add under spec.template.spec:
# tolerations:
# - key: "maintenance"
#   operator: "Equal"
#   value: "true"
#   effect: "NoSchedule"

# Or tolerate all taints:
# tolerations:
# - operator: "Exists"
```

---

## Scenario 9: Node Cordoned (Unschedulable)
**Problem:** New pods not scheduling on node

**NOTE:** Cordoning marks node as unschedulable - existing pods stay, new pods don't come!

### Symptoms:
```bash
kubectl get nodes
# NAME       STATUS                     ROLES    AGE   VERSION
# worker-1   Ready,SchedulingDisabled   <none>   5d    v1.28.0

kubectl describe pod webapp-abc123
# Events: 0/3 nodes available: 1 node(s) were unschedulable
```

**Fix: Uncordon the node**
```bash
# Uncordon node to allow scheduling
kubectl uncordon worker-1

# Verify
kubectl get nodes
# NAME       STATUS   ROLES    AGE   VERSION
# worker-1   Ready    <none>   5d    v1.28.0
```

---

## Scenario 10: Kubelet Can't Pull Images
**Problem:** All pods on node stuck in ImagePullBackOff

**NOTE:** Node-level issue - registry credentials, network, or DNS problem!

### Symptoms:
```bash
kubectl get pods -o wide | grep worker-1
# All pods on worker-1 showing ImagePullBackOff

kubectl describe pod webapp-abc123
# Events: Failed to pull image: connection timeout
```

### Troubleshooting Steps:

```bash
# Step 1: Test image pull from node
ssh user@worker-1
sudo crictl pull nginx:latest

# Step 2: Check network connectivity
curl -I https://registry-1.docker.io
ping 8.8.8.8

# Step 3: Check DNS resolution
nslookup registry-1.docker.io
```

**Fix 1: Network/Firewall blocking registry**
```bash
# Test connectivity to registry
curl -v https://registry-1.docker.io

# Check firewall rules
sudo iptables -L -n

# Allow HTTPS traffic
sudo iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Or disable firewall temporarily
sudo systemctl stop firewalld
```

**Fix 2: DNS not working**
```bash
# Check DNS configuration
cat /etc/resolv.conf

# Test DNS
nslookup registry-1.docker.io

# If DNS broken, add Google DNS temporarily
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf

# Restart containerd
sudo systemctl restart containerd
```

**Fix 3: Proxy configuration needed**
```bash
# If behind corporate proxy
sudo mkdir -p /etc/systemd/system/containerd.service.d/
sudo vi /etc/systemd/system/containerd.service.d/http-proxy.conf

# Add:
# [Service]
# Environment="HTTP_PROXY=http://proxy:8080"
# Environment="HTTPS_PROXY=http://proxy:8080"
# Environment="NO_PROXY=localhost,127.0.0.1,10.0.0.0/8"

sudo systemctl daemon-reload
sudo systemctl restart containerd
sudo systemctl restart kubelet
```

---

## Emergency Commands for Worker Nodes 🚨

```bash
# 1. Quick node status
kubectl get nodes -o wide

# 2. Describe node (most important!)
kubectl describe node <node-name>

# 3. Check kubelet logs
ssh <node> "sudo journalctl -u kubelet -f"

# 4. Restart kubelet
ssh <node> "sudo systemctl restart kubelet"

# 5. Check disk space
ssh <node> "df -h"

# 6. Check memory
ssh <node> "free -h"

# 7. Clean up images
ssh <node> "sudo crictl rmi --prune"

# 8. Check container runtime
ssh <node> "sudo systemctl status containerd"

# 9. Drain node (move pods away)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# 10. Uncordon node (allow scheduling)
kubectl uncordon <node-name>

# 11. Cordon node (prevent new pods)
kubectl cordon <node-name>

# 12. Remove node from cluster
kubectl delete node <node-name>

# 13. Check node taints
kubectl describe node <node-name> | grep Taints

# 14. Remove taint
kubectl taint nodes <node-name> <taint-key>-

# 15. Get all pods on specific node
kubectl get pods -A -o wide --field-selector spec.nodeName=<node-name>
```

---

## Worker Node Troubleshooting Checklist ✅

### When node is NotReady:
- [ ] Kubelet running? `systemctl status kubelet`
- [ ] Check kubelet logs? `journalctl -u kubelet`
- [ ] Network to control plane? `curl -k https://<control-plane>:6443`
- [ ] Certificates valid? Check expiration dates
- [ ] Container runtime running? `systemctl status containerd`
- [ ] Disk space available? `df -h`
- [ ] Memory available? `free -h`

### When pods not scheduling on node:
- [ ] Node Ready? `kubectl get nodes`
- [ ] Node cordoned? Check for "SchedulingDisabled"
- [ ] Node tainted? `kubectl describe node | grep Taints`
- [ ] Resource pressure? Check DiskPressure, MemoryPressure
- [ ] Pod tolerations match taints?

### When pods stuck ContainerCreating:
- [ ] Container runtime working? `crictl ps`
- [ ] CNI plugin installed? `ls /opt/cni/bin/`
- [ ] CNI config exists? `ls /etc/cni/net.d/`
- [ ] IP forwarding enabled? `cat /proc/sys/net/ipv4/ip_forward`
- [ ] Check pod events? `kubectl describe pod`

---

## Common Worker Node Issues Summary 📋

| Issue | Symptom | Quick Fix |
|-------|---------|-----------|
| NotReady | Node shows NotReady | Restart kubelet |
| Disk Full | DiskPressure=True | Clean images/logs |
| Memory Full | MemoryPressure=True | Add limits, drain pods |
| Cert Expired | Can't auth to control plane | Renew certificates |
| Runtime Down | Pods stuck ContainerCreating | Restart containerd |
| CNI Missing | Pods no IP address | Install CNI plugin |
| Cordoned | No new pods scheduling | Uncordon node |
| Tainted | Pods avoiding node | Remove taint |
| PID Pressure | Can't create processes | Increase pid_max |
| Network Issue | Can't pull images | Check firewall/DNS |

---

**Master these scenarios and you'll handle any worker node issue in production! 💪🚀**
