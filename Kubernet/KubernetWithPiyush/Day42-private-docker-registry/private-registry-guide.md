# Private Docker Registry Guide 🏪
## Host Your Own Container Images

---

## What is Private Registry? 🤔

**Private Registry** = Your own Docker Hub for private images

**Why Use:**
- Store proprietary images
- Faster pulls (local network)
- Control access
- No rate limits

---

## Setting Up Registry 🛠️

### Method 1: Docker Registry

```bash
# Run registry container
docker run -d \
  -p 5000:5000 \
  --name registry \
  -v registry-data:/var/lib/registry \
  registry:2

# Test
curl http://localhost:5000/v2/_catalog
```

### Method 2: In Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: docker-registry
spec:
  replicas: 1
  selector:
    matchLabels:
      app: registry
  template:
    metadata:
      labels:
        app: registry
    spec:
      containers:
      - name: registry
        image: registry:2
        ports:
        - containerPort: 5000
        volumeMounts:
        - name: registry-storage
          mountPath: /var/lib/registry
      volumes:
      - name: registry-storage
        persistentVolumeClaim:
          claimName: registry-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: docker-registry
spec:
  selector:
    app: registry
  ports:
  - port: 5000
    targetPort: 5000
  type: NodePort
```

---

## Using Private Registry 📝

### 1. Tag Image

```bash
# Tag image for private registry
docker tag nginx:latest localhost:5000/nginx:latest
```

### 2. Push Image

```bash
# Push to private registry
docker push localhost:5000/nginx:latest
```

### 3. Pull Image

```bash
# Pull from private registry
docker pull localhost:5000/nginx:latest
```

---

## Kubernetes with Private Registry 🚀

### Create Secret

```bash
# Create docker registry secret
kubectl create secret docker-registry regcred \
  --docker-server=myregistry.com:5000 \
  --docker-username=admin \
  --docker-password=password \
  --docker-email=admin@example.com
```

### Use in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-pod
spec:
  containers:
  - name: app
    image: myregistry.com:5000/myapp:latest
  imagePullSecrets:
  - name: regcred
```

---

## Secure Registry with TLS 🔐

```bash
# Generate certificates
openssl req -newkey rsa:4096 -nodes -sha256 \
  -keyout domain.key -x509 -days 365 -out domain.crt

# Run registry with TLS
docker run -d \
  -p 5000:5000 \
  --name registry \
  -v $(pwd)/certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  registry:2
```

---

## Registry with Authentication 🔑

```bash
# Create htpasswd file
docker run --rm --entrypoint htpasswd \
  httpd:2 -Bbn admin password > htpasswd

# Run registry with auth
docker run -d \
  -p 5000:5000 \
  --name registry \
  -v $(pwd)/htpasswd:/auth/htpasswd \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
  registry:2

# Login
docker login localhost:5000
```

---

## Best Practices 📚

### 1. Use TLS
```bash
# Always use HTTPS in production
```

### 2. Enable Authentication
```bash
# Protect your registry
```

### 3. Backup Registry Data
```bash
# Backup /var/lib/registry
```

### 4. Use Persistent Storage
```yaml
# PVC for registry data
```

---

## Key Takeaways 🎯

1. **Private Registry** = Your own image store
2. **Use for** = Proprietary images
3. **Secure** = TLS + Authentication
4. **imagePullSecrets** = Access from Kubernetes
5. **Backup** = Registry data

**Private Registry = Control Your Images! 🏪**
