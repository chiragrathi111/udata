# Application Failure Troubleshooting Guide 🔥
## From Beginner to Master Level

---

## Scenario 1: Service Not Routing to Pods (Most Common!)
**Problem:** Application deployed but can't access it through Service

**NOTE:** Service uses labels to find pods - if labels don't match, no traffic flows!

### Symptoms:
```bash
kubectl get pods
# NAME                    READY   STATUS    RESTARTS   AGE
# webapp-abc123           1/1     Running   0          5m

kubectl get svc
# NAME      TYPE        CLUSTER-IP      PORT(S)
# webapp    ClusterIP   10.96.100.50    80/TCP

curl http://10.96.100.50
# Connection refused or timeout
```

### Troubleshooting Steps:

```bash
# Step 1: Check if service has endpoints (MOST IMPORTANT!)
kubectl get endpoints webapp
# NAME      ENDPOINTS
# webapp    <none>        # ❌ BAD - No endpoints means selector mismatch!

# If you see pod IPs here, service is working correctly
# NAME      ENDPOINTS
# webapp    10.244.1.5:8080,10.244.2.3:8080  # ✅ GOOD
```

**Fix 1: Label Mismatch (90% of service issues!)**
```bash
# Check service selector
kubectl get svc webapp -o yaml | grep -A 3 selector
# Output:
#   selector:
#     app: web-app    # Service looking for "web-app"

# Check pod labels
kubectl get pods --show-labels
# NAME            LABELS
# webapp-abc123   app=webapp    # ❌ Pod has "webapp" not "web-app"

# FIX Option 1: Update pod labels
kubectl label pod webapp-abc123 app=web-app --overwrite

# FIX Option 2: Update service selector
kubectl edit svc webapp
# Change selector to match pod labels

# Verify endpoints now exist
kubectl get endpoints webapp
# Should show pod IPs now!
```

**Fix 2: Wrong TargetPort**
```bash
# Service configuration:
kubectl get svc webapp -o yaml
# ports:
# - port: 80          # External port (what you connect to)
#   targetPort: 8080  # Pod port (where app listens)

# Check what port your app actually listens on
kubectl get pod webapp-abc123 -o yaml | grep containerPort
#   - containerPort: 3000    # ❌ App listens on 3000, not 8080!

# Fix: Update service targetPort
kubectl edit svc webapp
# Change targetPort: 3000

# Or patch it quickly
kubectl patch svc webapp -p '{"spec":{"ports":[{"port":80,"targetPort":3000}]}}'
```

**Fix 3: Test pod directly (bypass service)**
```bash
# Get pod IP
kubectl get pod webapp-abc123 -o wide
# IP: 10.244.1.5

# Test pod directly
kubectl run test-pod --image=curlimages/curl -it --rm -- curl http://10.244.1.5:3000

# If this works but service doesn't:
# - Problem is with service configuration
# If this fails:
# - Problem is with the application itself
```

---

## Scenario 2: Database Connection Failures
**Problem:** Application can't connect to database

**NOTE:** In Kubernetes, use Service DNS names, not localhost or IPs!

### Symptoms:
```bash
kubectl logs webapp-abc123
# Error: connect ECONNREFUSED 127.0.0.1:5432
# Or: getaddrinfo ENOTFOUND localhost
```

### Troubleshooting Steps:

```bash
# Step 1: Check database pod is running
kubectl get pods | grep db
# mysql-db-xyz789   1/1   Running   0   10m

# Step 2: Check database service exists
kubectl get svc | grep db
# mysql-service   ClusterIP   10.96.50.100   3306/TCP

# Step 3: Check app environment variables
kubectl exec webapp-abc123 -- env | grep -i db
# DB_HOST=localhost    # ❌ WRONG! Should be service name
```

**Fix 1: Wrong Database Host**
```bash
# Application should use Service DNS name, not localhost!
# Format: <service-name>.<namespace>.svc.cluster.local
# Or simply: <service-name> (if in same namespace)

# Update deployment environment variables
kubectl set env deployment/webapp DB_HOST=mysql-service

# Or edit deployment
kubectl edit deployment webapp
# env:
# - name: DB_HOST
#   value: mysql-service    # Use service name!
# - name: DB_PORT
#   value: "3306"
# - name: DB_NAME
#   value: myapp
```

**Fix 2: Test DNS resolution from pod**
```bash
# Enter the application pod
kubectl exec -it webapp-abc123 -- sh

# Test DNS resolution
nslookup mysql-service
# Should return service IP

# Test connection to database
nc -zv mysql-service 3306
# Or
telnet mysql-service 3306

# If DNS fails, check CoreDNS
kubectl get pods -n kube-system | grep coredns
```

**Fix 3: Database credentials wrong**
```bash
# Check if secret exists
kubectl get secrets

# Check secret content (base64 encoded)
kubectl get secret db-credentials -o yaml

# Decode to verify
kubectl get secret db-credentials -o jsonpath='{.data.password}' | base64 -d

# Update deployment to use secret
kubectl edit deployment webapp
# env:
# - name: DB_PASSWORD
#   valueFrom:
#     secretKeyRef:
#       name: db-credentials
#       key: password
```

---

## Scenario 3: Application CrashLoopBackOff
**Problem:** Application starts but immediately crashes

**NOTE:** Check logs FIRST - they tell you exactly what's wrong!

### Symptoms:
```bash
kubectl get pods
# NAME            READY   STATUS             RESTARTS   AGE
# webapp-abc123   0/1     CrashLoopBackOff   5          3m
```

### Troubleshooting Steps:

```bash
# Step 1: Check current logs
kubectl logs webapp-abc123

# Step 2: Check previous crash logs (IMPORTANT!)
kubectl logs webapp-abc123 --previous

# Step 3: Check pod events
kubectl describe pod webapp-abc123 | grep -A 10 Events
```

**Common Crash Reasons & Fixes:**

**Crash 1: Missing Environment Variables**
```bash
# Logs show:
# Error: DB_HOST is not defined
# Error: Required environment variable missing

# Fix: Add missing env vars
kubectl set env deployment/webapp \
  DB_HOST=mysql-service \
  DB_PORT=3306 \
  DB_NAME=myapp

# Or use ConfigMap
kubectl create configmap app-config \
  --from-literal=DB_HOST=mysql-service \
  --from-literal=DB_PORT=3306

kubectl set env deployment/webapp --from=configmap/app-config
```

**Crash 2: Port Already in Use**
```bash
# Logs show:
# Error: listen EADDRINUSE: address already in use :::8080

# This happens when:
# 1. Multiple containers in pod using same port
# 2. Application trying to bind to privileged port (<1024)

# Fix: Change application port or container port
kubectl edit deployment webapp
# containers:
# - name: webapp
#   ports:
#   - containerPort: 8080    # Make sure this matches app
```

**Crash 3: File/Directory Not Found**
```bash
# Logs show:
# Error: ENOENT: no such file or directory, open '/app/config.json'

# Fix: Mount ConfigMap or Secret as file
kubectl create configmap app-config --from-file=config.json

kubectl edit deployment webapp
# volumeMounts:
# - name: config
#   mountPath: /app/config.json
#   subPath: config.json
# volumes:
# - name: config
#   configMap:
#     name: app-config
```

**Crash 4: Out of Memory (OOMKilled)**
```bash
# Check if pod was killed by OOM
kubectl describe pod webapp-abc123 | grep -i oom
# Last State: Terminated
#   Reason: OOMKilled

# Fix: Increase memory limits
kubectl set resources deployment webapp \
  --limits=memory=512Mi \
  --requests=memory=256Mi

# Or edit deployment
kubectl edit deployment webapp
# resources:
#   limits:
#     memory: "512Mi"
#   requests:
#     memory: "256Mi"
```

---

## Scenario 4: Liveness/Readiness Probe Failures
**Problem:** Kubernetes keeps killing healthy pods

**NOTE:** Probes check if app is alive and ready - misconfigured probes kill good pods!

### Symptoms:
```bash
kubectl get pods
# NAME            READY   STATUS    RESTARTS   AGE
# webapp-abc123   0/1     Running   15         5m    # High restarts!

kubectl describe pod webapp-abc123
# Liveness probe failed: HTTP probe failed with statuscode: 500
# Readiness probe failed: Get http://10.244.1.5:8080/health: dial tcp: connect: connection refused
```

### Troubleshooting Steps:

```bash
# Step 1: Check probe configuration
kubectl get pod webapp-abc123 -o yaml | grep -A 10 livenessProbe

# Step 2: Test probe endpoint manually
kubectl exec webapp-abc123 -- curl http://localhost:8080/health

# Step 3: Check application startup time
kubectl logs webapp-abc123 | grep -i "server started"
```

**Fix 1: Probe starts too early**
```bash
# Application takes 60 seconds to start
# But probe starts checking after 10 seconds
# Result: Kubernetes kills pod before it's ready!

kubectl edit deployment webapp
# livenessProbe:
#   httpGet:
#     path: /health
#     port: 8080
#   initialDelaySeconds: 90    # Increased from 10 to 90
#   periodSeconds: 10
#   timeoutSeconds: 5
#   failureThreshold: 3
```

**Fix 2: Wrong probe endpoint**
```bash
# Probe checking /health but app doesn't have that endpoint

# Option 1: Add health endpoint to your application
# (Best practice - every app should have health check)

# Option 2: Use different probe type
kubectl edit deployment webapp
# livenessProbe:
#   tcpSocket:          # Just check if port is open
#     port: 8080
#   initialDelaySeconds: 30

# Option 3: Use exec probe
# livenessProbe:
#   exec:
#     command:
#     - cat
#     - /tmp/healthy
#   initialDelaySeconds: 30
```

**Fix 3: Probe timeout too short**
```bash
# Application slow to respond, probe times out

kubectl edit deployment webapp
# livenessProbe:
#   httpGet:
#     path: /health
#     port: 8080
#   initialDelaySeconds: 30
#   periodSeconds: 10
#   timeoutSeconds: 10      # Increased from 1 to 10
#   failureThreshold: 5     # Increased from 3 to 5
```

---

## Scenario 5: ConfigMap/Secret Not Loading
**Problem:** Application can't read configuration

**NOTE:** ConfigMaps and Secrets must exist BEFORE pod starts!

### Symptoms:
```bash
kubectl get pods
# NAME            READY   STATUS                  RESTARTS   AGE
# webapp-abc123   0/1     CreateContainerConfigError   0      1m

kubectl describe pod webapp-abc123
# Error: configmap "app-config" not found
```

### Troubleshooting Steps:

```bash
# Step 1: Check if ConfigMap/Secret exists
kubectl get configmap
kubectl get secret

# Step 2: Check if names match
kubectl get pod webapp-abc123 -o yaml | grep -A 5 configMap

# Step 3: Check namespace (common mistake!)
kubectl get configmap -n production
```

**Fix 1: Create missing ConfigMap**
```bash
# Create from literal values
kubectl create configmap app-config \
  --from-literal=API_URL=https://api.example.com \
  --from-literal=LOG_LEVEL=info

# Create from file
kubectl create configmap app-config --from-file=config.json

# Create from env file
kubectl create configmap app-config --from-env-file=app.env
```

**Fix 2: Wrong namespace**
```bash
# ConfigMap in 'default' namespace
# Pod in 'production' namespace
# Result: Pod can't find ConfigMap!

# Fix: Create ConfigMap in correct namespace
kubectl create configmap app-config \
  --from-literal=API_URL=https://api.example.com \
  -n production

# Or move pod to correct namespace
```

**Fix 3: Mount path conflicts**
```bash
# ConfigMap mounted at /app/config
# But application looks for /config

kubectl edit deployment webapp
# volumeMounts:
# - name: config
#   mountPath: /config    # Changed from /app/config
# volumes:
# - name: config
#   configMap:
#     name: app-config
```

---

## Scenario 6: Multi-Container Pod Communication
**Problem:** Containers in same pod can't communicate

**NOTE:** Containers in same pod share network namespace - use localhost!

### Symptoms:
```bash
# Main app container can't reach sidecar container
kubectl logs webapp-abc123 -c main-app
# Error: connect ECONNREFUSED 10.244.1.5:9090
```

### Troubleshooting Steps:

```bash
# Step 1: List all containers in pod
kubectl get pod webapp-abc123 -o jsonpath='{.spec.containers[*].name}'

# Step 2: Check logs of each container
kubectl logs webapp-abc123 -c main-app
kubectl logs webapp-abc123 -c sidecar

# Step 3: Check if sidecar is running
kubectl get pod webapp-abc123 -o jsonpath='{.status.containerStatuses[*].state}'
```

**Fix: Use localhost, not pod IP**
```bash
# ❌ WRONG: Trying to connect to pod IP
# APP_SIDECAR_URL=http://10.244.1.5:9090

# ✅ CORRECT: Use localhost (containers share network)
kubectl set env deployment/webapp APP_SIDECAR_URL=http://localhost:9090

# Containers in same pod communicate via localhost:
# - main-app listens on :8080
# - sidecar listens on :9090
# - They reach each other via localhost
```

---

## Scenario 7: Persistent Volume Issues
**Problem:** Application can't write to disk

**NOTE:** PVC must be bound to PV before pod can use it!

### Symptoms:
```bash
kubectl get pods
# NAME            READY   STATUS              RESTARTS   AGE
# webapp-abc123   0/1     ContainerCreating   0          5m

kubectl describe pod webapp-abc123
# Events: Unable to attach or mount volumes: unmounted volumes=[data]
```

### Troubleshooting Steps:

```bash
# Step 1: Check PVC status
kubectl get pvc
# NAME        STATUS    VOLUME    CAPACITY   ACCESS MODES
# app-data    Pending   -         -          -           # ❌ Not bound!

# Step 2: Describe PVC for errors
kubectl describe pvc app-data

# Step 3: Check if PV exists
kubectl get pv
```

**Fix 1: No StorageClass**
```bash
# Check available storage classes
kubectl get storageclass

# If none, create one (example for local storage)
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF

# Update PVC to use storage class
kubectl edit pvc app-data
# storageClassName: local-storage
```

**Fix 2: Permission denied writing to volume**
```bash
# Logs show:
# Error: EACCES: permission denied, open '/data/file.txt'

# This happens when:
# - Volume owned by root
# - App runs as non-root user

# Fix: Set security context
kubectl edit deployment webapp
# spec:
#   template:
#     spec:
#       securityContext:
#         fsGroup: 1000      # Group ID
#       containers:
#       - name: webapp
#         securityContext:
#           runAsUser: 1000  # User ID
```

**Fix 3: Volume already mounted elsewhere**
```bash
# PV with ReadWriteOnce can only be used by one pod at a time

# Check which pod is using the volume
kubectl get pods -o wide | grep Running

# Either:
# 1. Use ReadWriteMany access mode (if supported)
kubectl edit pvc app-data
# accessModes:
# - ReadWriteMany

# 2. Or scale down other pods using same volume
kubectl scale deployment other-app --replicas=0
```

---

## Scenario 8: NetworkPolicy Blocking Traffic
**Problem:** Pods can't communicate even though everything looks correct

**NOTE:** NetworkPolicy is like a firewall - blocks all traffic by default!

### Symptoms:
```bash
# Frontend can't reach backend
kubectl exec frontend-pod -- curl http://backend-service
# Connection timeout

# But backend is running fine
kubectl get pods | grep backend
# backend-abc123   1/1   Running   0   10m
```

### Troubleshooting Steps:

```bash
# Step 1: Check if NetworkPolicies exist
kubectl get networkpolicy

# Step 2: Describe NetworkPolicy
kubectl describe networkpolicy backend-policy

# Step 3: Test without NetworkPolicy
kubectl delete networkpolicy backend-policy
# Try connection again
```

**Fix 1: Allow ingress traffic**
```bash
# Create NetworkPolicy to allow frontend → backend
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-allow-frontend
spec:
  podSelector:
    matchLabels:
      app: backend        # Apply to backend pods
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend   # Allow from frontend pods
    ports:
    - protocol: TCP
      port: 8080
EOF
```

**Fix 2: Allow egress traffic**
```bash
# Frontend can't make outbound connections

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-allow-egress
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 8080
  - to:              # Allow DNS
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
EOF
```

**Fix 3: Allow all traffic (for testing)**
```bash
# Temporarily allow all traffic to debug
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - {}
  egress:
  - {}
EOF

# Once working, create specific policies
```

---

## Scenario 9: DNS Resolution Failures
**Problem:** Pods can't resolve service names

**NOTE:** CoreDNS provides DNS for Kubernetes - if it's down, nothing works!

### Symptoms:
```bash
kubectl exec webapp-abc123 -- nslookup backend-service
# Server: 10.96.0.10
# Address: 10.96.0.10:53
# ** server can't find backend-service: NXDOMAIN
```

### Troubleshooting Steps:

```bash
# Step 1: Check CoreDNS pods
kubectl get pods -n kube-system | grep coredns
# coredns-abc123   1/1   Running   0   1d

# Step 2: Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# Step 3: Test DNS from pod
kubectl run test-dns --image=busybox -it --rm -- nslookup kubernetes.default
```

**Fix 1: CoreDNS not running**
```bash
# Restart CoreDNS
kubectl rollout restart deployment coredns -n kube-system

# If still not working, check CoreDNS config
kubectl get configmap coredns -n kube-system -o yaml
```

**Fix 2: Wrong DNS search domain**
```bash
# Check pod's DNS config
kubectl exec webapp-abc123 -- cat /etc/resolv.conf
# nameserver 10.96.0.10
# search default.svc.cluster.local svc.cluster.local cluster.local

# If service in different namespace, use FQDN:
# backend-service.production.svc.cluster.local
```

**Fix 3: Use IP instead of DNS (temporary)**
```bash
# Get service IP
kubectl get svc backend-service -o jsonpath='{.spec.clusterIP}'
# 10.96.100.50

# Use IP temporarily while fixing DNS
kubectl set env deployment/webapp BACKEND_URL=http://10.96.100.50:8080
```

---

## Scenario 10: Resource Limits Causing Issues
**Problem:** Application slow or getting killed

**NOTE:** Limits too low = app killed; Requests too high = pod not scheduled!

### Symptoms:
```bash
# App very slow
kubectl top pod webapp-abc123
# NAME            CPU    MEMORY
# webapp-abc123   500m   490Mi    # Near limit!

# Or pod keeps restarting
kubectl describe pod webapp-abc123 | grep -i oom
# Reason: OOMKilled
```

### Troubleshooting Steps:

```bash
# Step 1: Check current resource usage
kubectl top pod webapp-abc123

# Step 2: Check resource limits
kubectl get pod webapp-abc123 -o yaml | grep -A 10 resources

# Step 3: Check node resources
kubectl describe node | grep -A 5 "Allocated resources"
```

**Fix 1: Increase limits**
```bash
# Current limits too low
kubectl set resources deployment webapp \
  --limits=cpu=1000m,memory=1Gi \
  --requests=cpu=500m,memory=512Mi

# Or edit deployment
kubectl edit deployment webapp
# resources:
#   limits:
#     cpu: "1000m"
#     memory: "1Gi"
#   requests:
#     cpu: "500m"
#     memory: "512Mi"
```

**Fix 2: Remove limits (for testing)**
```bash
# Temporarily remove limits to see if that's the issue
kubectl edit deployment webapp
# Delete the entire resources section

# If app works without limits, gradually add them back
```

**Fix 3: Optimize application**
```bash
# Instead of just increasing limits, optimize app:
# - Fix memory leaks
# - Add caching
# - Optimize database queries
# - Use connection pooling

# Monitor after optimization
kubectl top pod webapp-abc123 --containers
```

---

## Quick Debugging Commands 🔧

```bash
# 1. Check everything about a pod
kubectl describe pod <pod-name>

# 2. Get logs (current)
kubectl logs <pod-name>

# 3. Get logs (previous crash)
kubectl logs <pod-name> --previous

# 4. Get logs from specific container
kubectl logs <pod-name> -c <container-name>

# 5. Follow logs in real-time
kubectl logs -f <pod-name>

# 6. Execute command in pod
kubectl exec <pod-name> -- <command>

# 7. Interactive shell in pod
kubectl exec -it <pod-name> -- /bin/sh

# 8. Check service endpoints
kubectl get endpoints <service-name>

# 9. Test service from another pod
kubectl run test --image=curlimages/curl -it --rm -- curl http://<service-name>

# 10. Port forward to local machine
kubectl port-forward pod/<pod-name> 8080:8080

# 11. Check pod labels
kubectl get pods --show-labels

# 12. Check events (recent issues)
kubectl get events --sort-by='.lastTimestamp'

# 13. Check resource usage
kubectl top pods

# 14. Get pod YAML
kubectl get pod <pod-name> -o yaml

# 15. Check all in namespace
kubectl get all -n <namespace>
```

---

## Application Debugging Checklist ✅

### When app not accessible:
- [ ] Pod running? `kubectl get pods`
- [ ] Check logs? `kubectl logs <pod>`
- [ ] Service exists? `kubectl get svc`
- [ ] Endpoints exist? `kubectl get endpoints`
- [ ] Labels match? `kubectl get pods --show-labels`
- [ ] Correct ports? Check targetPort vs containerPort
- [ ] NetworkPolicy blocking? `kubectl get networkpolicy`

### When app crashing:
- [ ] Check current logs? `kubectl logs <pod>`
- [ ] Check previous logs? `kubectl logs <pod> --previous`
- [ ] Describe pod? `kubectl describe pod <pod>`
- [ ] Resource limits? `kubectl top pod <pod>`
- [ ] Probes configured correctly?
- [ ] Environment variables set?
- [ ] ConfigMaps/Secrets exist?

### When app can't connect to database:
- [ ] DB pod running? `kubectl get pods | grep db`
- [ ] DB service exists? `kubectl get svc | grep db`
- [ ] Using service name (not localhost)?
- [ ] Correct credentials?
- [ ] DNS working? `nslookup <service-name>`
- [ ] NetworkPolicy allowing traffic?

---

## Pro Tips 💡

### 1. Always check labels first!
```bash
# 90% of service issues are label mismatches
kubectl get pods --show-labels
kubectl get svc <service-name> -o yaml | grep -A 3 selector
```

### 2. Use describe for everything
```bash
# Events section shows recent issues
kubectl describe pod <pod-name>
kubectl describe svc <service-name>
kubectl describe node <node-name>
```

### 3. Test connectivity step by step
```bash
# 1. Can pod reach itself?
kubectl exec <pod> -- curl localhost:8080

# 2. Can other pod reach it by IP?
kubectl exec <other-pod> -- curl http://<pod-ip>:8080

# 3. Can other pod reach it by service?
kubectl exec <other-pod> -- curl http://<service-name>:8080
```

### 4. Create debug pod
```bash
# Pod with all networking tools
kubectl run debug --image=nicolaka/netshoot -it --rm -- /bin/bash

# Inside debug pod:
nslookup <service-name>
curl http://<service-name>
ping <pod-ip>
telnet <service-name> 8080
```

### 5. Check from inside the pod
```bash
# See what the app sees
kubectl exec -it <pod-name> -- sh

# Check environment
env | grep -i db

# Check DNS
cat /etc/resolv.conf

# Check network
netstat -tulpn

# Check files
ls -la /app
```

---

## Common Mistakes to Avoid ❌

1. **Using localhost for database** - Use service name!
2. **Label typos** - app vs app-name vs application
3. **Wrong namespace** - ConfigMap in default, pod in production
4. **Forgetting targetPort** - Service port ≠ container port
5. **Probes too aggressive** - App needs time to start
6. **No resource limits** - One pod can crash entire node
7. **Hardcoded IPs** - Always use service names
8. **Not checking logs** - Logs tell you everything!

---

**Practice these scenarios and you'll master Kubernetes troubleshooting! 🚀**
