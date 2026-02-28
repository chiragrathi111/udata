# Quick Start Guide 🚀

## Get Both Projects Running in 10 Minutes

---

## Prerequisites

```bash
# Check if you have these installed:
docker --version
kubectl version --client
```

**Need to install?**
- Docker Desktop: https://www.docker.com/products/docker-desktop
- Enable Kubernetes in Docker Desktop settings

---

## Project 1: E-Commerce Platform

### Step 1: Deploy
```bash
cd project1-ecommerce
./deploy.sh
```

### Step 2: Wait (2-3 minutes)
Watch pods starting:
```bash
kubectl get pods -n ecommerce -w
```

### Step 3: Access
```bash
# Open in browser
http://localhost:30080
```

### Step 4: Test API
```bash
# Get products
curl http://localhost:30080/api/products

# Get users
curl http://localhost:30080/api/users

# Get orders
curl http://localhost:30080/api/orders
```

### Step 5: See Auto-Scaling
```bash
kubectl get hpa -n ecommerce
```

---

## Project 2: Private Registry

### Step 1: Deploy
```bash
cd ../project2-registry
./setup.sh
```

### Step 2: Wait (1-2 minutes)
```bash
kubectl get pods -n registry -w
```

### Step 3: Access UI
```bash
# Open in browser
http://localhost:30800
```

### Step 4: Push an Image
```bash
# Login
docker login localhost:30500
# Username: admin
# Password: admin123

# Tag image
docker tag nginx:latest localhost:30500/nginx:latest

# Push
docker push localhost:30500/nginx:latest
```

### Step 5: View in UI
Refresh http://localhost:30800 - you'll see your nginx image!

---

## Verify Everything Works

### Project 1 Checklist:
- [ ] All 7 pods running: `kubectl get pods -n ecommerce`
- [ ] Frontend accessible: http://localhost:30080
- [ ] API returns data: `curl http://localhost:30080/api/products`
- [ ] HPA configured: `kubectl get hpa -n ecommerce`

### Project 2 Checklist:
- [ ] Registry pod running: `kubectl get pods -n registry`
- [ ] UI accessible: http://localhost:30800
- [ ] Can push images: `docker push localhost:30500/nginx:latest`
- [ ] Backup CronJob exists: `kubectl get cronjob -n registry`

---

## Common Issues & Fixes

### Issue: Pods stuck in "Pending"
```bash
# Check events
kubectl describe pod <pod-name> -n <namespace>

# Usually means no storage class
# Docker Desktop should have one by default
kubectl get storageclass
```

### Issue: Can't access localhost:30080
```bash
# Check if service exists
kubectl get svc -n ecommerce

# Try port-forward instead
kubectl port-forward -n ecommerce svc/frontend 8080:80
# Then visit: http://localhost:8080
```

### Issue: Docker login fails
```bash
# Make sure registry is running
kubectl get pods -n registry

# Check logs
kubectl logs -n registry deployment/docker-registry
```

---

## Cleanup

### Remove Project 1:
```bash
kubectl delete namespace ecommerce
```

### Remove Project 2:
```bash
kubectl delete namespace registry
```

### Remove Both:
```bash
kubectl delete namespace ecommerce registry
```

---

## Next Steps

1. ✅ Both projects running
2. 📖 Read individual project READMEs
3. 🎤 Study INTERVIEW-GUIDE.md
4. 🧪 Experiment with scaling, updates
5. 💼 Add to resume
6. 🎯 Practice explaining to friends

---

## Useful Commands

```bash
# Watch all resources
kubectl get all -n ecommerce
kubectl get all -n registry

# View logs
kubectl logs -f deployment/<name> -n <namespace>

# Check resource usage
kubectl top pods -n ecommerce
kubectl top nodes

# Scale manually
kubectl scale deployment product-service --replicas=5 -n ecommerce

# Execute into pod
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh

# Port forward
kubectl port-forward -n ecommerce svc/api-gateway 3000:3000
```

---

**You're ready to impress interviewers! 🎉**
