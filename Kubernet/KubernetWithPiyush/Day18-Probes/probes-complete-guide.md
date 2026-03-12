# Liveness & Readiness Probes Guide 🏥
## Health Checks for Pods

---

## What are Probes? 🤔

**Probes** = Health checks for containers

**Types:**
1. **Liveness Probe** - Is container alive?
2. **Readiness Probe** - Is container ready for traffic?
3. **Startup Probe** - Has container started?

---

## Why Use Probes? 💡

### Without Probes:
```
Container crashes → Kubernetes doesn't know → Sends traffic → Errors ❌
```

### With Probes:
```
Container crashes → Liveness fails → Kubernetes restarts → Fixed ✅
Container starting → Readiness fails → No traffic → Safe ✅
```

---

## Liveness Probe 💓

**Purpose:** Detect if container is alive
**Action:** Restart container if fails

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
  - name: app
    image: nginx
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 3
```

**What happens:**
- Wait 30 seconds after start
- Check /health every 10 seconds
- If fails 3 times → Restart container

---

## Readiness Probe 🚦

**Purpose:** Detect if container ready for traffic
**Action:** Remove from service if fails

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
  - name: app
    image: nginx
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 5
      timeoutSeconds: 3
      failureThreshold: 3
```

**What happens:**
- Wait 10 seconds after start
- Check /ready every 5 seconds
- If fails → Remove from service endpoints
- If passes → Add back to service

---

## Probe Types 🔍

### 1. HTTP GET
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
    httpHeaders:
    - name: Custom-Header
      value: Awesome
```

### 2. TCP Socket
```yaml
livenessProbe:
  tcpSocket:
    port: 3306
```

### 3. Exec Command
```yaml
livenessProbe:
  exec:
    command:
    - cat
    - /tmp/healthy
```

---

## Real-World Example 🌍

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: production-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: myapi:v2.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
        # Liveness: Restart if unhealthy
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        # Readiness: Remove from service if not ready
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        # Startup: Wait for slow startup
        startupProbe:
          httpGet:
            path: /startup
            port: 8080
          initialDelaySeconds: 0
          periodSeconds: 10
          timeoutSeconds: 3
          failureThreshold: 30
```

---

## Best Practices 📚

### 1. Always Use Both Probes
```yaml
livenessProbe: {}   # Restart if dead
readinessProbe: {}  # Remove from service if not ready
```

### 2. Set Appropriate Delays
```yaml
# App takes 60s to start
initialDelaySeconds: 60
```

### 3. Don't Make Probes Too Aggressive
```yaml
# ✅ Good
periodSeconds: 10
failureThreshold: 3

# ❌ Bad (too aggressive)
periodSeconds: 1
failureThreshold: 1
```

### 4. Use Different Endpoints
```yaml
livenessProbe:
  path: /health      # Basic health
readinessProbe:
  path: /ready       # Ready for traffic (checks DB, etc.)
```

---

## Troubleshooting 🔍

### Issue 1: Pod keeps restarting
```bash
# Check restart count
kubectl get pods
# RESTARTS: 10

# Check liveness probe
kubectl describe pod webapp
# Liveness probe failed

# Solution: Increase initialDelaySeconds or fix health endpoint
```

### Issue 2: Pod not receiving traffic
```bash
# Check endpoints
kubectl get endpoints webapp-service
# No endpoints

# Check readiness probe
kubectl describe pod webapp
# Readiness probe failed

# Solution: Fix readiness endpoint
```

---

## Key Takeaways 🎯

1. **Liveness** = Restart if dead
2. **Readiness** = Remove from service if not ready
3. **Startup** = Wait for slow startup
4. **Always use** = Both liveness and readiness
5. **Set delays** = Match app startup time

**Probes = Automatic Health Management! 🏥**
