# Project 1: Microservices E-Commerce Platform 🛒

## Production-Ready Kubernetes Application

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│              INGRESS (Load Balancer)            │
└────────────────┬────────────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
   ┌────▼─────┐    ┌─────▼────┐
   │ Frontend │    │   API    │
   │ (Nginx)  │    │ Gateway  │
   └──────────┘    └─────┬────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   ┌────▼─────┐   ┌─────▼────┐   ┌──────▼──────┐
   │ Product  │   │   User   │   │    Order    │
   │ Service  │   │ Service  │   │   Service   │
   └────┬─────┘   └─────┬────┘   └──────┬──────┘
        │               │                │
        └───────────────┼────────────────┘
                        │
                ┌───────┴────────┐
                │                │
         ┌──────▼──────┐  ┌─────▼─────┐
         │  MongoDB    │  │   Redis   │
         │ (StatefulSet)│  │  (Cache)  │
         └─────────────┘  └───────────┘
```

---

## 📦 Components

1. **Frontend** - Nginx serving static files
2. **API Gateway** - Routes requests to services
3. **Product Service** - Manages product catalog
4. **User Service** - Authentication & user management
5. **Order Service** - Order processing
6. **MongoDB** - Persistent database (StatefulSet)
7. **Redis** - Caching layer

---

## 🚀 Quick Deploy

```bash
# Deploy everything
kubectl apply -f kubernetes/

# Check status
kubectl get pods -n ecommerce

# Get access URL
kubectl get ingress -n ecommerce
```

---

## 📋 Features Demonstrated

### 1. Namespace Isolation
```yaml
# Separate namespace for organization
```

### 2. ConfigMaps & Secrets
```yaml
# Environment configuration
# Database credentials
```

### 3. Persistent Storage
```yaml
# StatefulSet for MongoDB
# PersistentVolumeClaims
```

### 4. Auto-Scaling
```yaml
# HorizontalPodAutoscaler
# CPU-based scaling
```

### 5. Service Discovery
```yaml
# ClusterIP services
# DNS-based discovery
```

### 6. Load Balancing
```yaml
# Ingress controller
# Multiple replicas
```

---

## 🎤 Interview Talking Points

### Q: "Tell me about your Kubernetes project"

**Answer:**
"I built a microservices e-commerce platform with 7 components. The frontend is Nginx serving a React app, behind that is an API gateway that routes to three backend services - Product, User, and Order services. For data persistence, I used MongoDB as a StatefulSet with persistent volumes, and Redis for caching frequently accessed data.

I implemented horizontal pod autoscaling on the API services to handle traffic spikes, configured ingress for external access, and used ConfigMaps for environment variables and Secrets for sensitive data like database passwords. The entire setup demonstrates service discovery, load balancing, and production-ready practices."

### Q: "How did you handle data persistence?"

**Answer:**
"I used StatefulSets for MongoDB because it requires stable network identities and persistent storage. Each pod gets a PersistentVolumeClaim that survives pod restarts. I configured a headless service for direct pod access and used init containers to handle database initialization. For Redis, I used a Deployment since it's just a cache and data loss is acceptable."

### Q: "How does auto-scaling work in your project?"

**Answer:**
"I implemented HorizontalPodAutoscaler on the API services. When CPU usage exceeds 70%, Kubernetes automatically creates new pods up to a maximum of 10 replicas. When load decreases, it scales down to the minimum of 2 replicas. This ensures the application handles traffic spikes while optimizing resource usage during low traffic."

### Q: "How do services communicate?"

**Answer:**
"Services use Kubernetes DNS for discovery. For example, the API Gateway calls 'http://product-service:3000' and Kubernetes resolves it to the correct pod IPs. All internal communication uses ClusterIP services, which aren't exposed externally. Only the Ingress controller is exposed via LoadBalancer or NodePort."

---

## 🔧 Customization Guide

### Change Replica Counts:
```yaml
# In deployment files
spec:
  replicas: 3  # Change this
```

### Modify Resource Limits:
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Update Environment Variables:
```bash
# Edit configmap
kubectl edit configmap app-config -n ecommerce
```

---

## 🐛 Troubleshooting

### Pods not starting?
```bash
kubectl describe pod <pod-name> -n ecommerce
kubectl logs <pod-name> -n ecommerce
```

### Service not accessible?
```bash
kubectl get svc -n ecommerce
kubectl get endpoints -n ecommerce
```

### Database connection issues?
```bash
kubectl exec -it mongodb-0 -n ecommerce -- mongosh
```

---

## 📊 Monitoring

### Check Resource Usage:
```bash
kubectl top pods -n ecommerce
kubectl top nodes
```

### View Logs:
```bash
kubectl logs -f deployment/api-gateway -n ecommerce
```

### Check HPA Status:
```bash
kubectl get hpa -n ecommerce
```

---

## 🎯 Key Learnings

1. **Microservices Architecture** - Service separation and communication
2. **StatefulSets** - Managing stateful applications
3. **Auto-Scaling** - Dynamic resource management
4. **Service Discovery** - DNS-based service location
5. **Persistent Storage** - Data that survives pod restarts
6. **ConfigMaps/Secrets** - Configuration management
7. **Ingress** - External access and routing

---

## 💡 Next Steps

1. Add monitoring with Prometheus
2. Implement CI/CD pipeline
3. Add health checks and readiness probes
4. Implement service mesh (Istio)
5. Add logging with ELK stack

---

**This project shows you understand production Kubernetes! 🚀**
