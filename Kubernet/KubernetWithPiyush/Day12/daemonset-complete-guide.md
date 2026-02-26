# DaemonSet Complete Guide 🔄
## One Pod Per Node

---

## What is DaemonSet? 🤔

**DaemonSet** ensures that a copy of a pod runs on ALL (or selected) nodes in the cluster.

**Think of it like:**
- Security guard at every floor of building
- One guard per floor, always
- New floor added? New guard assigned automatically
- Floor removed? Guard removed automatically

**Key Difference from Deployment:**
```
Deployment: You say "I want 3 pods" (anywhere in cluster)
DaemonSet: You say "I want 1 pod on EVERY node"
```

---

## Why Use DaemonSet? 💡

### Use Cases:
1. **Monitoring Agents** - Prometheus node-exporter on every node
2. **Logging Agents** - Fluentd, Filebeat on every node
3. **Storage Daemons** - Ceph, GlusterFS on every node
4. **Network Plugins** - CNI plugins on every node
5. **Security Agents** - Antivirus, intrusion detection

### When to Use:
- ✅ Need pod on every node
- ✅ Node-level operations
- ✅ Monitoring/logging
- ✅ System daemons

### When NOT to Use:
- ❌ Application servers (use Deployment)
- ❌ Databases (use StatefulSet)
- ❌ Jobs (use Job/CronJob)

---

## DaemonSet vs Deployment 🆚

```
Deployment (3 replicas):
Node1: pod1, pod2
Node2: pod3
Node3: (none)

DaemonSet:
Node1: pod1
Node2: pod2
Node3: pod3
```

| Feature | Deployment | DaemonSet |
|---------|------------|-----------|
| **Replicas** | You specify (e.g., 3) | Auto (1 per node) |
| **Scheduling** | Random nodes | All nodes |
| **Scaling** | Manual/HPA | Auto with nodes |
| **Use Case** | Applications | System daemons |

---

## Your DaemonSet Example 📝

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: my-daemonset
  labels:
    app: my-app-ds
spec:
  selector:
    matchLabels:
      app: my-app-ds
  template:
    metadata:
      labels:
        app: my-app-ds
    spec:
      containers:
      - name: my-container
        image: nginx:latest
        ports:
        - containerPort: 80
```

**What happens:**
```
3 nodes in cluster
  ↓
DaemonSet creates 3 pods (1 per node)
  ↓
Add 4th node
  ↓
DaemonSet automatically creates pod on new node
  ↓
Now 4 pods (1 per node)
```

---

## Real-World Example 1: Monitoring 📊

### Scenario: Prometheus Node Exporter on every node

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostNetwork: true        # Use host network
      hostPID: true            # Access host processes
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
          hostPort: 9100       # Expose on node
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
```

**Why DaemonSet?**
- Need metrics from EVERY node
- Each node-exporter monitors its own node
- Auto-scales with cluster size

---

## Real-World Example 2: Logging 📝

### Scenario: Fluentd log collector on every node

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      serviceAccountName: fluentd
      containers:
      - name: fluentd
        image: fluent/fluentd-kubernetes-daemonset:v1
        env:
        - name: FLUENT_ELASTICSEARCH_HOST
          value: "elasticsearch.logging.svc.cluster.local"
        - name: FLUENT_ELASTICSEARCH_PORT
          value: "9200"
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```

**Why DaemonSet?**
- Collects logs from ALL nodes
- Each Fluentd reads logs from its node
- Sends to central Elasticsearch

---

## Real-World Example 3: Network Plugin 🌐

### Scenario: Calico CNI on every node

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: calico-node
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: calico-node
  template:
    metadata:
      labels:
        k8s-app: calico-node
    spec:
      hostNetwork: true
      tolerations:
      - operator: Exists        # Run on all nodes including master
      containers:
      - name: calico-node
        image: calico/node:v3.24.0
        env:
        - name: DATASTORE_TYPE
          value: "kubernetes"
        - name: CALICO_NETWORKING_BACKEND
          value: "bird"
        securityContext:
          privileged: true
        volumeMounts:
        - name: lib-modules
          mountPath: /lib/modules
          readOnly: true
      volumes:
      - name: lib-modules
        hostPath:
          path: /lib/modules
```

**Why DaemonSet?**
- Every node needs networking
- Calico provides pod networking
- Must run on ALL nodes

---

## Node Selection 🎯

### Run on Specific Nodes Only:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ssd-monitor
spec:
  selector:
    matchLabels:
      app: ssd-monitor
  template:
    metadata:
      labels:
        app: ssd-monitor
    spec:
      nodeSelector:
        disktype: ssd          # Only nodes with this label
      containers:
      - name: monitor
        image: ssd-monitor:latest
```

**Result:**
```
Node1 (disktype=ssd): pod created ✅
Node2 (disktype=hdd): no pod ❌
Node3 (disktype=ssd): pod created ✅
```

---

## Tolerations for Master Nodes 🔐

### Run on Master Nodes Too:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: monitoring-agent
spec:
  selector:
    matchLabels:
      app: monitoring
  template:
    metadata:
      labels:
        app: monitoring
    spec:
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      - key: node-role.kubernetes.io/control-plane
        effect: NoSchedule
      containers:
      - name: agent
        image: monitoring-agent:latest
```

**Why?**
- Master nodes have taints by default
- Prevents regular pods from running
- Tolerations allow DaemonSet to run there

---

## Update Strategies 🔄

### 1. RollingUpdate (Default)

```yaml
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1        # Update 1 node at a time
```

**How it works:**
```
1. Update pod on Node1
2. Wait for it to be ready
3. Update pod on Node2
4. Wait for it to be ready
5. Continue...
```

### 2. OnDelete

```yaml
spec:
  updateStrategy:
    type: OnDelete
```

**How it works:**
```
1. Update DaemonSet
2. Pods NOT updated automatically
3. Delete pod manually
4. New pod created with new version
```

---

## Common Commands 🔧

```bash
# Create DaemonSet
kubectl apply -f ds.yml

# Get DaemonSets
kubectl get daemonsets
kubectl get ds

# Get DaemonSets in all namespaces
kubectl get ds -A

# Describe DaemonSet
kubectl describe ds my-daemonset

# Get pods created by DaemonSet
kubectl get pods -l app=my-app-ds

# Update image
kubectl set image ds/my-daemonset my-container=nginx:1.21

# Check rollout status
kubectl rollout status ds/my-daemonset

# Rollout history
kubectl rollout history ds/my-daemonset

# Rollback
kubectl rollout undo ds/my-daemonset

# Delete DaemonSet (deletes all pods!)
kubectl delete ds my-daemonset

# Get DaemonSet YAML
kubectl get ds my-daemonset -o yaml
```

---

## Real-World Scenario: Complete Monitoring Stack 📊

```yaml
# 1. Node Exporter DaemonSet
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
---
# 2. Service for Node Exporter
apiVersion: v1
kind: Service
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  clusterIP: None            # Headless service
  selector:
    app: node-exporter
  ports:
  - port: 9100
    targetPort: 9100
```

**Prometheus scrapes all node-exporters:**
```yaml
# Prometheus config
scrape_configs:
- job_name: 'kubernetes-nodes'
  kubernetes_sd_configs:
  - role: node
  relabel_configs:
  - source_labels: [__address__]
    target_label: __address__
    replacement: ${1}:9100
```

---

## Benefits & Drawbacks 📊

### Benefits:
- ✅ Auto-scales with cluster
- ✅ Ensures coverage on all nodes
- ✅ Automatic pod placement
- ✅ Self-healing
- ✅ Perfect for system daemons

### Drawbacks:
- ❌ Can't control pod count
- ❌ One pod per node only
- ❌ Resource usage on all nodes
- ❌ Not for application workloads

---

## Troubleshooting 🔍

### Issue 1: Pod not on all nodes

```bash
# Check DaemonSet status
kubectl get ds my-daemonset

# Check which nodes have pods
kubectl get pods -o wide -l app=my-app-ds

# Check node labels (if using nodeSelector)
kubectl get nodes --show-labels

# Check node taints
kubectl describe nodes | grep Taints
```

### Issue 2: Pods not starting

```bash
# Describe DaemonSet
kubectl describe ds my-daemonset

# Check pod status
kubectl get pods -l app=my-app-ds

# Check pod logs
kubectl logs <pod-name>

# Common causes:
# - Image pull errors
# - Resource constraints
# - Node taints
```

### Issue 3: Update stuck

```bash
# Check rollout status
kubectl rollout status ds/my-daemonset

# Check pod status
kubectl get pods -l app=my-app-ds

# If stuck, rollback
kubectl rollout undo ds/my-daemonset
```

---

## Best Practices 📚

### 1. Set Resource Limits
```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi
```

### 2. Use Tolerations for System DaemonSets
```yaml
tolerations:
- operator: Exists
```

### 3. Use hostNetwork Carefully
```yaml
# Only if needed for monitoring/networking
hostNetwork: true
```

### 4. Add Health Checks
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 9100
  initialDelaySeconds: 30
```

### 5. Use Specific Image Tags
```yaml
# ✅ Good
image: prom/node-exporter:v1.3.1

# ❌ Bad
image: prom/node-exporter:latest
```

---

## Key Takeaways 🎯

1. **DaemonSet** = One pod per node
2. **Auto-scales** = With cluster size
3. **Use for** = Monitoring, logging, networking
4. **Not for** = Application workloads
5. **Tolerations** = Run on master nodes
6. **nodeSelector** = Run on specific nodes
7. **Updates** = RollingUpdate or OnDelete

---

**DaemonSet = System Daemon on Every Node! 🔄**
