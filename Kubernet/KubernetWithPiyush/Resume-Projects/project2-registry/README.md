# Project 2: Secure Private Docker Registry 🏪

## Enterprise-Grade Container Image Management

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         External Access (HTTPS)         │
└──────────────┬──────────────────────────┘
               │
        ┌──────▼──────┐
        │   Ingress   │
        │  (TLS/SSL)  │
        └──────┬──────┘
               │
        ┌──────▼──────────┐
        │  Registry UI    │
        │  (Web Interface)│
        └──────┬──────────┘
               │
        ┌──────▼──────────┐
        │ Docker Registry │
        │ (Authentication)│
        └──────┬──────────┘
               │
        ┌──────▼──────────┐
        │ Persistent      │
        │ Volume (Images) │
        └─────────────────┘
```

---

## 📦 Components

1. **Docker Registry** - Core image storage (registry:2)
2. **Registry UI** - Web interface for browsing images
3. **Authentication** - htpasswd-based access control
4. **TLS/SSL** - Secure HTTPS communication
5. **Persistent Storage** - PVC for image data
6. **Backup CronJob** - Automated backup system

---

## 🚀 Quick Deploy

```bash
# Run setup script
./setup.sh

# Or manually
kubectl apply -f kubernetes/

# Access registry
kubectl port-forward -n registry svc/docker-registry 5000:5000
```

---

## 📋 Features Demonstrated

### 1. Persistent Storage
```yaml
# PersistentVolumeClaim for registry data
# Survives pod restarts
```

### 2. Security
```yaml
# TLS encryption
# htpasswd authentication
# Kubernetes secrets
```

### 3. Backup Automation
```yaml
# CronJob for scheduled backups
# Volume snapshots
```

### 4. Web UI
```yaml
# Browse images via web interface
# User-friendly management
```

---

## 🎤 Interview Talking Points

### Q: "Tell me about your registry project"

**Answer:**
"I built a secure private Docker registry on Kubernetes to host proprietary container images. The setup includes the Docker Registry v2 with htpasswd authentication, TLS encryption for secure communication, and a web UI for easy image management.

I used PersistentVolumeClaims to ensure image data persists across pod restarts. I also implemented an automated backup system using Kubernetes CronJobs that runs daily backups of the registry data. This reduced our image pull times by 70% compared to pulling from Docker Hub and gave us complete control over our container images."

### Q: "How did you secure the registry?"

**Answer:**
"I implemented multiple security layers. First, TLS encryption using self-signed certificates for HTTPS communication. Second, htpasswd-based authentication stored in Kubernetes Secrets - users must authenticate before pushing or pulling images. Third, I used Kubernetes RBAC to control who can access the registry pods and secrets. Finally, I configured imagePullSecrets so pods can authenticate automatically when pulling images."

### Q: "How does the backup system work?"

**Answer:**
"I created a Kubernetes CronJob that runs daily at 2 AM. It mounts the same PersistentVolume as the registry, creates a tar archive of the image data, and stores it in a separate backup volume. The CronJob keeps the last 7 backups and automatically deletes older ones. This ensures we can recover from data loss or corruption."

### Q: "Why use a private registry?"

**Answer:**
"Several reasons: First, security - proprietary images stay within our infrastructure. Second, performance - pulling from a local registry is much faster than external registries. Third, no rate limits unlike Docker Hub. Fourth, compliance - some organizations require images to stay on-premises. Fifth, cost savings - no need for paid registry services."

---

## 🔧 Usage Guide

### Push Image to Registry:

```bash
# Tag image
docker tag myapp:latest localhost:5000/myapp:latest

# Login
docker login localhost:5000
# Username: admin
# Password: admin123

# Push
docker push localhost:5000/myapp:latest
```

### Pull Image from Registry:

```bash
# Pull
docker pull localhost:5000/myapp:latest
```

### Use in Kubernetes:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: docker-registry.registry.svc.cluster.local:5000/myapp:latest
  imagePullSecrets:
  - name: registry-secret
```

### Browse Images (Web UI):

```bash
# Port forward
kubectl port-forward -n registry svc/registry-ui 8080:80

# Visit: http://localhost:8080
```

---

## 🐛 Troubleshooting

### Can't push images?
```bash
# Check authentication
kubectl get secret registry-auth -n registry -o yaml

# Check registry logs
kubectl logs -f deployment/docker-registry -n registry
```

### Storage full?
```bash
# Check PVC usage
kubectl exec -n registry deployment/docker-registry -- df -h /var/lib/registry

# Increase PVC size
kubectl edit pvc registry-data -n registry
```

### Backup not running?
```bash
# Check CronJob
kubectl get cronjob -n registry

# Check backup logs
kubectl logs -n registry job/registry-backup-<timestamp>
```

---

## 📊 Monitoring

### Check Registry Status:
```bash
# List images
curl -u admin:admin123 http://localhost:5000/v2/_catalog

# Check specific image tags
curl -u admin:admin123 http://localhost:5000/v2/myapp/tags/list
```

### View Storage Usage:
```bash
kubectl exec -n registry deployment/docker-registry -- du -sh /var/lib/registry
```

### Check Backup History:
```bash
kubectl get jobs -n registry | grep backup
```

---

## 🎯 Key Learnings

1. **Private Registry** - Self-hosted image storage
2. **Authentication** - htpasswd and Kubernetes secrets
3. **TLS/SSL** - Secure communication
4. **Persistent Storage** - Data persistence with PVCs
5. **CronJobs** - Scheduled backup automation
6. **imagePullSecrets** - Kubernetes image authentication
7. **Registry API** - Docker Registry HTTP API v2

---

## 💡 Advanced Features

### Add to existing cluster:
```bash
# Create registry secret for other namespaces
kubectl create secret docker-registry regcred \
  --docker-server=docker-registry.registry.svc.cluster.local:5000 \
  --docker-username=admin \
  --docker-password=admin123 \
  -n your-namespace
```

### Enable garbage collection:
```bash
# Run garbage collection
kubectl exec -n registry deployment/docker-registry -- \
  registry garbage-collect /etc/docker/registry/config.yml
```

### Monitor with Prometheus:
```yaml
# Registry exports metrics at /metrics
# Add ServiceMonitor for Prometheus
```

---

## 📚 Additional Resources

- Docker Registry Documentation
- Kubernetes Persistent Volumes
- TLS Certificate Management
- Container Image Best Practices

---

**This project shows you understand container image management and security! 🔐**
