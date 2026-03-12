# ConfigMaps Complete Guide 🗂️
## Configuration Management

---

## What is ConfigMap? 🤔

**ConfigMap** = Store configuration data separately from application code

**Think of it like:**
- App = Car
- ConfigMap = GPS settings
- Change destination without rebuilding car!

---

## Why Use ConfigMaps? 💡

### Without ConfigMap:
```
Dev: DATABASE_URL=dev-db (hardcoded in image)
Prod: DATABASE_URL=prod-db (need different image)
❌ Multiple images for different environments
```

### With ConfigMap:
```
Same image everywhere ✅
Different ConfigMap per environment ✅
Change config without rebuilding ✅
```

---

## Creating ConfigMaps 🛠️

### Method 1: From Literal Values
```bash
kubectl create configmap app-config \
  --from-literal=DATABASE_URL=mysql://db:3306 \
  --from-literal=LOG_LEVEL=info
```

### Method 2: From File
```bash
kubectl create configmap app-config \
  --from-file=config.properties
```

### Method 3: From YAML
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_URL: "mysql://db:3306"
  LOG_LEVEL: "info"
  API_KEY: "abc123"
```

---

## Using ConfigMaps 📝

### 1. As Environment Variables
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
  - name: app
    image: myapp:latest
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: DATABASE_URL
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: LOG_LEVEL
```

### 2. As Volume (Files)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: config
      mountPath: /etc/config
  volumes:
  - name: config
    configMap:
      name: app-config
```

**Result:**
```
/etc/config/DATABASE_URL (file with value)
/etc/config/LOG_LEVEL (file with value)
```

### 3. All Keys as Env Vars
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
  - name: app
    image: myapp:latest
    envFrom:
    - configMapRef:
        name: app-config
```

---

## Real-World Example 🌍

```yaml
# ConfigMap for different environments
---
# Development
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: dev
data:
  DATABASE_URL: "mysql://dev-db:3306/myapp"
  REDIS_URL: "redis://dev-redis:6379"
  LOG_LEVEL: "debug"
  FEATURE_NEW_UI: "true"
---
# Production
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: production
data:
  DATABASE_URL: "mysql://prod-db:3306/myapp"
  REDIS_URL: "redis://prod-redis:6379"
  LOG_LEVEL: "error"
  FEATURE_NEW_UI: "false"
---
# Deployment (same for both)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: app
        image: myapp:v2.0
        envFrom:
        - configMapRef:
            name: app-config
```

---

## Commands 🔧

```bash
# Create ConfigMap
kubectl create configmap app-config --from-literal=KEY=value

# Get ConfigMaps
kubectl get configmap
kubectl get cm

# Describe ConfigMap
kubectl describe cm app-config

# View ConfigMap data
kubectl get cm app-config -o yaml

# Edit ConfigMap
kubectl edit cm app-config

# Delete ConfigMap
kubectl delete cm app-config
```

---

## Best Practices 📚

### 1. One ConfigMap per App
```yaml
# ✅ Good
name: webapp-config
name: api-config

# ❌ Bad
name: all-configs
```

### 2. Use Namespaces
```yaml
metadata:
  name: app-config
  namespace: production
```

### 3. Don't Store Secrets
```yaml
# ❌ Bad (use Secret instead)
data:
  PASSWORD: "secret123"

# ✅ Good
data:
  DATABASE_URL: "mysql://db:3306"
```

### 4. Version ConfigMaps
```yaml
# ✅ Good
name: app-config-v2
name: app-config-v3
```

---

## Troubleshooting 🔍

### Issue 1: ConfigMap not found
```bash
# Check if exists
kubectl get cm app-config

# Check namespace
kubectl get cm app-config -n production
```

### Issue 2: Pod not getting config
```bash
# Check pod env vars
kubectl exec webapp -- env

# Check mounted files
kubectl exec webapp -- ls /etc/config
```

---

## Key Takeaways 🎯

1. **ConfigMap** = Store configuration
2. **Separate** = Config from code
3. **Use for** = Non-sensitive data
4. **Not for** = Passwords (use Secrets)
5. **Per environment** = Different ConfigMaps

**ConfigMaps = Configuration Made Easy! 🗂️**
