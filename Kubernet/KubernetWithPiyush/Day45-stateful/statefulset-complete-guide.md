# StatefulSet Complete Guide 🗄️
## Why, When, and How to Use StatefulSets

---

## What is StatefulSet? 🤔

**StatefulSet** is a Kubernetes workload for managing **stateful applications** - apps that need:
- Stable, unique network identifiers
- Stable, persistent storage
- Ordered deployment and scaling
- Ordered rolling updates

**Think of it like this:**
- **Deployment** = Hotel rooms (any room is fine, interchangeable)
- **StatefulSet** = Apartment building (each unit has specific number, residents care which one)

---

## Deployment vs StatefulSet 🆚

### Deployment (Stateless Apps):

```
┌─────────────────────────────────────┐
│         Deployment                  │
├─────────────────────────────────────┤
│  Pod: webapp-abc123  (random name)  │
│  Pod: webapp-xyz789  (random name)  │
│  Pod: webapp-def456  (random name)  │
└─────────────────────────────────────┘

Characteristics:
✅ Pods are interchangeable
✅ Any pod can handle any request
✅ No specific identity needed
✅ Can scale up/down randomly
✅ Storage is optional

Examples: Web servers, APIs, Frontend apps
```

### StatefulSet (Stateful Apps):

```
┌─────────────────────────────────────┐
│         StatefulSet                 │
├─────────────────────────────────────┤
│  Pod: mongodb-0  (fixed name)       │
│  Pod: mongodb-1  (fixed name)       │
│  Pod: mongodb-2  (fixed name)       │
└─────────────────────────────────────┘

Characteristics:
✅ Pods have stable, unique names
✅ Each pod has specific role/identity
✅ Ordered startup (0 → 1 → 2)
✅ Ordered shutdown (2 → 1 → 0)
✅ Each pod has own persistent storage

Examples: Databases, Message queues, Distributed systems
```

---

## Why Use StatefulSet? 💡

### Problem WITHOUT StatefulSet:

```yaml
# Using Deployment for database (BAD IDEA!)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: mysql
        image: mysql:8.0

# Problems:
# ❌ Pod names change: mysql-abc123, mysql-xyz789
# ❌ Can't identify which is master, which is replica
# ❌ Storage gets mixed up when pods restart
# ❌ No guaranteed order of startup
# ❌ Data loss risk!
```

### Solution WITH StatefulSet:

```yaml
# Using StatefulSet for database (CORRECT!)
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  replicas: 3
  serviceName: mysql
  template:
    spec:
      containers:
      - name: mysql
        image: mysql:8.0

# Benefits:
# ✅ Stable names: mysql-0, mysql-1, mysql-2
# ✅ mysql-0 = master, mysql-1/2 = replicas
# ✅ Each pod has own persistent volume
# ✅ Ordered startup: 0 → 1 → 2
# ✅ Data is safe!
```

---

## StatefulSet Features 🎯

### 1. Stable Network Identity

```
Deployment Pods (Random Names):
webapp-abc123  ← Changes on restart
webapp-xyz789  ← Changes on restart
webapp-def456  ← Changes on restart

StatefulSet Pods (Fixed Names):
mongodb-0  ← Always mongodb-0
mongodb-1  ← Always mongodb-1
mongodb-2  ← Always mongodb-2
```

**DNS Names:**
```
mongodb-0.mongodb-service.default.svc.cluster.local
mongodb-1.mongodb-service.default.svc.cluster.local
mongodb-2.mongodb-service.default.svc.cluster.local
```

### 2. Stable Storage

```
Deployment:
┌──────────┐     ┌──────────┐
│  Pod-1   │────▶│   PVC    │
└──────────┘     └──────────┘
     ↓ (restart)
┌──────────┐     ┌──────────┐
│  Pod-2   │────▶│ New PVC? │  ❌ Lost data!
└──────────┘     └──────────┘

StatefulSet:
┌──────────┐     ┌──────────┐
│mongodb-0 │────▶│  PVC-0   │
└──────────┘     └──────────┘
     ↓ (restart)
┌──────────┐     ┌──────────┐
│mongodb-0 │────▶│  PVC-0   │  ✅ Same data!
└──────────┘     └──────────┘
```

### 3. Ordered Operations

**Deployment (Random Order):**
```
Scale Up:   Pod-1, Pod-3, Pod-2  (any order)
Scale Down: Pod-2, Pod-1, Pod-3  (any order)
```

**StatefulSet (Ordered):**
```
Scale Up:   mongodb-0 → mongodb-1 → mongodb-2  (sequential)
Scale Down: mongodb-2 → mongodb-1 → mongodb-0  (reverse)
```

---

## Real-World Example 1: MongoDB Cluster 🍃

### Scenario: 3-node MongoDB replica set

```
┌─────────────────────────────────────────────────┐
│              MongoDB StatefulSet                │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌────────┴────┐
│  │  mongodb-0   │  │  mongodb-1   │  │  mongodb-2  │
│  │   (PRIMARY)  │  │  (SECONDARY) │  │ (SECONDARY) │
│  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘
│         │                 │                  │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼──────┐
│  │   PVC-0      │  │   PVC-1      │  │   PVC-2     │
│  │   (1Gi)      │  │   (1Gi)      │  │   (1Gi)     │
│  └──────────────┘  └──────────────┘  └─────────────┘
└─────────────────────────────────────────────────────┘
```

**Your StatefulSet (from Day45):**

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
spec:
  serviceName: mongodb-service    # Headless service for DNS
  replicas: 3                     # 3 MongoDB nodes
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:4.4
        ports:
        - containerPort: 27017
          name: db
        volumeMounts:
        - name: data
          mountPath: /data/db     # MongoDB data directory
  
  # Each pod gets its own PVC!
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "mongodb-sc"
      resources:
        requests:
          storage: 1Gi
```

**What happens:**
1. Creates `mongodb-0` with `data-mongodb-0` PVC
2. Waits for `mongodb-0` to be Ready
3. Creates `mongodb-1` with `data-mongodb-1` PVC
4. Waits for `mongodb-1` to be Ready
5. Creates `mongodb-2` with `data-mongodb-2` PVC

**Headless Service (required!):**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongodb-service
spec:
  clusterIP: None              # Headless service!
  selector:
    app: mongodb
  ports:
  - port: 27017
    targetPort: 27017
```

**Why headless?** Each pod needs its own DNS name!

---

## Real-World Example 2: MySQL Master-Slave 🐬

### Scenario: 1 Master + 2 Replicas

```
┌─────────────────────────────────────────────────┐
│              MySQL StatefulSet                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────┐                               │
│  │   mysql-0    │  ← MASTER (Read/Write)        │
│  └──────┬───────┘                               │
│         │                                        │
│    ┌────┴────┐                                  │
│    │         │                                   │
│  ┌─▼────────▼┐  ┌──────────────┐               │
│  │  mysql-1  │  │   mysql-2    │               │
│  │ (REPLICA) │  │  (REPLICA)   │               │
│  │ Read-only │  │  Read-only   │               │
│  └───────────┘  └──────────────┘               │
│                                                 │
│  Replication: mysql-0 → mysql-1, mysql-2        │
└─────────────────────────────────────────────────┘
```

**StatefulSet Configuration:**

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      initContainers:
      # Init container to configure master/slave
      - name: init-mysql
        image: mysql:8.0
        command:
        - bash
        - "-c"
        - |
          set -ex
          # Generate server-id from pod ordinal
          [[ $(hostname) =~ -([0-9]+)$ ]] || exit 1
          ordinal=${BASH_REMATCH[1]}
          echo [mysqld] > /mnt/conf.d/server-id.cnf
          echo server-id=$((100 + $ordinal)) >> /mnt/conf.d/server-id.cnf
          # mysql-0 is master, others are replicas
          if [[ $ordinal -eq 0 ]]; then
            cp /mnt/config-map/master.cnf /mnt/conf.d/
          else
            cp /mnt/config-map/slave.cnf /mnt/conf.d/
          fi
        volumeMounts:
        - name: conf
          mountPath: /mnt/conf.d
        - name: config-map
          mountPath: /mnt/config-map
      
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "password123"
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
      
      volumes:
      - name: conf
        emptyDir: {}
      - name: config-map
        configMap:
          name: mysql-config
  
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

---

## Real-World Example 3: Kafka Cluster 📨

### Scenario: 3-broker Kafka cluster

```
┌─────────────────────────────────────────────────┐
│              Kafka StatefulSet                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌────────┴────┐
│  │   kafka-0    │  │   kafka-1    │  │   kafka-2   │
│  │  Broker ID:0 │  │  Broker ID:1 │  │ Broker ID:2 │
│  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘
│         │                 │                  │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼──────┐
│  │   Logs-0     │  │   Logs-1     │  │   Logs-2    │
│  │   (10Gi)     │  │   (10Gi)     │  │   (10Gi)    │
│  └──────────────┘  └──────────────┘  └─────────────┘
│                                                 │
│  Each broker has unique ID and storage          │
└─────────────────────────────────────────────────┘
```

**Why StatefulSet for Kafka?**
- Each broker needs unique ID (0, 1, 2)
- Each broker stores different partitions
- Brokers need to find each other by name
- Data must persist across restarts

---

## StatefulSet Lifecycle Flowchart 📊

### Scaling Up (0 → 3 replicas):

```
START
  │
  ▼
Create mongodb-0
  │
  ▼
Wait for mongodb-0 Ready ⏳
  │
  ▼
mongodb-0 Ready? ──No──▶ Keep waiting
  │ Yes
  ▼
Create mongodb-1
  │
  ▼
Wait for mongodb-1 Ready ⏳
  │
  ▼
mongodb-1 Ready? ──No──▶ Keep waiting
  │ Yes
  ▼
Create mongodb-2
  │
  ▼
Wait for mongodb-2 Ready ⏳
  │
  ▼
mongodb-2 Ready? ──No──▶ Keep waiting
  │ Yes
  ▼
All Pods Running ✅
  │
  ▼
END
```

### Scaling Down (3 → 1 replicas):

```
START (3 replicas)
  │
  ▼
Delete mongodb-2 (highest ordinal first!)
  │
  ▼
Wait for mongodb-2 terminated ⏳
  │
  ▼
mongodb-2 deleted? ──No──▶ Keep waiting
  │ Yes
  ▼
Delete mongodb-1
  │
  ▼
Wait for mongodb-1 terminated ⏳
  │
  ▼
mongodb-1 deleted? ──No──▶ Keep waiting
  │ Yes
  ▼
Only mongodb-0 remains ✅
  │
  ▼
END

Note: PVCs are NOT deleted!
      (data-mongodb-1 and data-mongodb-2 still exist)
```

### Pod Restart Flow:

```
mongodb-1 crashes 💥
  │
  ▼
Kubernetes detects failure
  │
  ▼
Create new mongodb-1 pod
  │
  ▼
Attach SAME PVC (data-mongodb-1) ✅
  │
  ▼
Pod starts with existing data
  │
  ▼
Application continues normally 🎉
```

---

## Benefits of StatefulSet ✅

| Benefit | Description | Example |
|---------|-------------|---------|
| **Stable Identity** | Pods keep same name after restart | `mongodb-0` always `mongodb-0` |
| **Ordered Deployment** | Pods start in sequence | Master before replicas |
| **Ordered Scaling** | Scale up/down predictably | Add/remove one at a time |
| **Stable Storage** | Each pod keeps its data | Database data persists |
| **Stable Network** | Each pod has unique DNS | `mongodb-0.mongodb-service` |
| **Predictable Behavior** | Know which pod does what | Pod-0 = master, others = replicas |

---

## Drawbacks of StatefulSet ❌

| Drawback | Description | Impact |
|----------|-------------|--------|
| **Slower Scaling** | Must wait for each pod to be Ready | Can't scale quickly |
| **Complex Setup** | Need headless service, PVCs, etc. | More YAML to write |
| **Storage Management** | PVCs not auto-deleted | Manual cleanup needed |
| **Harder Debugging** | More moving parts | More things to check |
| **Resource Intensive** | Each pod needs own storage | Higher costs |
| **No Auto-Failover** | App must handle replication | Need app-level logic |

---

## When to Use StatefulSet? 🤔

### ✅ USE StatefulSet for:

1. **Databases**
   - MySQL, PostgreSQL, MongoDB
   - Each instance needs own data
   - Master-replica setup

2. **Message Queues**
   - Kafka, RabbitMQ, NATS
   - Brokers need unique IDs
   - Persistent message storage

3. **Distributed Systems**
   - Elasticsearch, Cassandra, Redis Cluster
   - Nodes need to find each other
   - Data sharding across nodes

4. **Caching Systems**
   - Redis, Memcached (with persistence)
   - Each node has different cache

5. **Coordination Services**
   - ZooKeeper, etcd, Consul
   - Need stable network identity

### ❌ DON'T USE StatefulSet for:

1. **Stateless Web Apps**
   - Use Deployment instead
   - Any pod can handle any request

2. **APIs**
   - Use Deployment
   - No need for stable identity

3. **Frontend Apps**
   - Use Deployment
   - No persistent data needed

4. **Batch Jobs**
   - Use Job or CronJob
   - Run once and done

5. **Simple Apps**
   - Use Deployment
   - StatefulSet is overkill

---

## StatefulSet vs Deployment Decision Tree 🌳

```
Do you need persistent storage?
  │
  ├─ No ──▶ Use Deployment
  │
  └─ Yes
      │
      Do pods need unique identity?
        │
        ├─ No ──▶ Use Deployment + PVC
        │
        └─ Yes
            │
            Do pods need ordered startup?
              │
              ├─ No ──▶ Maybe use Deployment
              │
              └─ Yes ──▶ Use StatefulSet ✅
```

---

## Complete Working Example 🚀

### MongoDB StatefulSet with All Components:

**1. StorageClass:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: mongodb-sc
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

**2. PersistentVolumes (for local testing):**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongodb-pv-0
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: mongodb-sc
  hostPath:
    path: /data/mongodb-0
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongodb-pv-1
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: mongodb-sc
  hostPath:
    path: /data/mongodb-1
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongodb-pv-2
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: mongodb-sc
  hostPath:
    path: /data/mongodb-2
```

**3. Headless Service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongodb-service
spec:
  clusterIP: None              # Headless!
  selector:
    app: mongodb
  ports:
  - port: 27017
    targetPort: 27017
    name: mongodb
```

**4. StatefulSet:**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
spec:
  serviceName: mongodb-service
  replicas: 3
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:4.4
        ports:
        - containerPort: 27017
          name: db
        volumeMounts:
        - name: data
          mountPath: /data/db
        env:
        - name: MONGO_INITDB_ROOT_USERNAME
          value: admin
        - name: MONGO_INITDB_ROOT_PASSWORD
          value: password123
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: mongodb-sc
      resources:
        requests:
          storage: 1Gi
```

**5. Deploy Everything:**
```bash
# Apply in order
kubectl apply -f storageclass.yaml
kubectl apply -f pv.yaml
kubectl apply -f service.yaml
kubectl apply -f statefulset.yaml

# Watch pods come up
kubectl get pods -w

# Check PVCs
kubectl get pvc

# Check services
kubectl get svc
```

**6. Test MongoDB:**
```bash
# Connect to mongodb-0
kubectl exec -it mongodb-0 -- mongo -u admin -p password123

# Inside mongo shell:
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongodb-0.mongodb-service:27017" },
    { _id: 1, host: "mongodb-1.mongodb-service:27017" },
    { _id: 2, host: "mongodb-2.mongodb-service:27017" }
  ]
})

# Check replica set status
rs.status()
```

---

## Common StatefulSet Commands 🔧

```bash
# Create StatefulSet
kubectl apply -f statefulset.yaml

# Get StatefulSet
kubectl get statefulset
kubectl get sts  # Short form

# Describe StatefulSet
kubectl describe sts mongodb

# Get pods
kubectl get pods -l app=mongodb

# Scale StatefulSet
kubectl scale sts mongodb --replicas=5

# Delete pod (will be recreated)
kubectl delete pod mongodb-1

# Delete StatefulSet (keeps PVCs!)
kubectl delete sts mongodb

# Delete StatefulSet and pods (still keeps PVCs!)
kubectl delete sts mongodb --cascade=foreground

# Delete everything including PVCs
kubectl delete sts mongodb
kubectl delete pvc -l app=mongodb

# Check PVCs
kubectl get pvc

# Exec into specific pod
kubectl exec -it mongodb-0 -- bash

# Check logs
kubectl logs mongodb-0

# Port forward
kubectl port-forward mongodb-0 27017:27017
```

---

## Troubleshooting StatefulSet 🔍

### Issue 1: Pods stuck in Pending

```bash
# Check PVC status
kubectl get pvc
# If Pending, check PV availability

# Check events
kubectl describe pod mongodb-0

# Common causes:
# - No PV available
# - StorageClass doesn't exist
# - Node doesn't have space
```

### Issue 2: Pods not starting in order

```bash
# Check if previous pod is Ready
kubectl get pods

# StatefulSet waits for each pod to be Ready
# Check readiness probe
kubectl describe pod mongodb-0
```

### Issue 3: PVC not deleted after scale down

```bash
# This is BY DESIGN!
# PVCs are kept for data safety

# To delete manually:
kubectl delete pvc data-mongodb-2
```

### Issue 4: Can't connect to pods

```bash
# Check headless service exists
kubectl get svc mongodb-service

# Check DNS
kubectl run test --image=busybox -it --rm -- nslookup mongodb-0.mongodb-service

# Should return IP address
```

---

## Best Practices 📚

### 1. Always use Headless Service
```yaml
spec:
  clusterIP: None  # Required for StatefulSet!
```

### 2. Set Pod Management Policy
```yaml
spec:
  podManagementPolicy: OrderedReady  # Default (safe)
  # Or: Parallel (faster but less safe)
```

### 3. Use Update Strategy
```yaml
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0  # Update all pods
```

### 4. Set Resource Limits
```yaml
resources:
  limits:
    cpu: "1000m"
    memory: "2Gi"
  requests:
    cpu: "500m"
    memory: "1Gi"
```

### 5. Use Init Containers
```yaml
initContainers:
- name: init-config
  image: busybox
  command: ['sh', '-c', 'echo "Initializing..."']
```

### 6. Add Readiness Probe
```yaml
readinessProbe:
  exec:
    command:
    - mongo
    - --eval
    - "db.adminCommand('ping')"
  initialDelaySeconds: 10
  periodSeconds: 5
```

---

## Summary: StatefulSet in a Nutshell 🥜

**Use StatefulSet when you need:**
- ✅ Stable pod names (mongodb-0, mongodb-1)
- ✅ Stable storage (each pod keeps its data)
- ✅ Ordered operations (start/stop in sequence)
- ✅ Unique pod identity (master vs replica)

**Don't use StatefulSet when:**
- ❌ Pods are interchangeable
- ❌ No persistent data needed
- ❌ Simple stateless app
- ❌ Need fast scaling

**Perfect for:**
- 🗄️ Databases (MySQL, PostgreSQL, MongoDB)
- 📨 Message Queues (Kafka, RabbitMQ)
- 🔍 Search Engines (Elasticsearch)
- 💾 Caching (Redis Cluster)
- 🔐 Coordination (ZooKeeper, etcd)

---

**StatefulSet = Stable Identity + Stable Storage + Ordered Operations! 🚀**
