# Interview Preparation Guide 🎤

## How to Present These Projects Confidently

---

## Project 1: E-Commerce Microservices

### Opening Statement (30 seconds):
"I built a production-ready microservices e-commerce platform on Kubernetes with 7 components including frontend, API gateway, three backend services, MongoDB, and Redis. It demonstrates auto-scaling, persistent storage, service discovery, and load balancing."

### Key Points to Mention:
1. **Architecture**: 3-tier with API Gateway pattern
2. **Scaling**: HPA scales services based on CPU (2-10 replicas)
3. **Storage**: StatefulSet for MongoDB with PVC
4. **Communication**: Service discovery via Kubernetes DNS
5. **Configuration**: ConfigMaps for env vars, Secrets for passwords

### Technical Deep Dive Questions:

**Q: Why use StatefulSet for MongoDB?**
"StatefulSets provide stable network identities and persistent storage. Each pod gets a unique name (mongodb-0) and its own PVC that survives restarts. This is critical for databases that need stable storage and network identity."

**Q: How does auto-scaling work?**
"I configured HorizontalPodAutoscaler to monitor CPU usage. When it exceeds 70%, Kubernetes creates new pods up to max 10 replicas. When load drops, it scales down to min 2 replicas. This optimizes resource usage while handling traffic spikes."

**Q: What happens if a pod crashes?**
"Kubernetes automatically restarts it. For stateless services (API, frontend), any pod can handle requests via load balancing. For MongoDB, the StatefulSet ensures the same pod name and PVC are used, preserving data."

---

## Project 2: Private Docker Registry

### Opening Statement (30 seconds):
"I built a secure private Docker registry on Kubernetes with authentication, TLS encryption, web UI, and automated backups. It reduced image pull times by 70% and gave us full control over proprietary images."

### Key Points to Mention:
1. **Security**: htpasswd auth + TLS encryption
2. **Storage**: PVC for image persistence
3. **Automation**: CronJob for daily backups
4. **UI**: Web interface for image management
5. **Integration**: imagePullSecrets for Kubernetes pods

### Technical Deep Dive Questions:

**Q: How did you implement authentication?**
"I used htpasswd-based authentication stored in Kubernetes Secrets. Users must provide username/password to push or pull images. The credentials are mounted into the registry pod as a file."

**Q: How does the backup system work?**
"A Kubernetes CronJob runs daily at 2 AM. It mounts the same PVC as the registry, creates a tar archive of /var/lib/registry, and stores it in a separate backup PVC. It keeps the last 7 backups and auto-deletes older ones."

**Q: Why use a private registry?**
"Four main reasons: Security (proprietary images stay internal), Performance (local pulls are faster), No rate limits (unlike Docker Hub), and Compliance (some orgs require on-premises storage)."

---

## Common Kubernetes Questions

### Q: What is a Pod?
"A Pod is the smallest deployable unit in Kubernetes. It's a wrapper around one or more containers that share network and storage. Containers in a pod can communicate via localhost."

### Q: Difference between Deployment and StatefulSet?
"Deployments are for stateless apps where any pod is interchangeable. StatefulSets are for stateful apps needing stable network identities and persistent storage. MongoDB uses StatefulSet, API services use Deployment."

### Q: What are Services?
"Services provide stable networking for pods. ClusterIP exposes pods internally, NodePort exposes on a node port, LoadBalancer gets an external IP. Services use selectors to find pods and load balance traffic."

### Q: What is a PersistentVolume?
"PVs provide storage that survives pod restarts. A PVC is a request for storage. When a pod uses a PVC, Kubernetes binds it to a PV. The data persists even if the pod is deleted."

### Q: How does Ingress work?
"Ingress manages external HTTP/HTTPS access. It routes traffic based on hostnames and paths to different services. It's like a reverse proxy that sits in front of your services."

---

## Troubleshooting Scenarios

### Scenario 1: Pod won't start
**Steps:**
1. `kubectl describe pod <name>` - Check events
2. `kubectl logs <name>` - Check application logs
3. Check image pull errors, resource limits, volume mounts

### Scenario 2: Service not accessible
**Steps:**
1. `kubectl get endpoints` - Verify pods are selected
2. `kubectl get svc` - Check service configuration
3. Test pod directly: `kubectl port-forward`

### Scenario 3: High memory usage
**Steps:**
1. `kubectl top pods` - Identify heavy pods
2. Check resource limits in deployment
3. Scale horizontally or increase limits

---

## Demo Script

### For Project 1:
```bash
# Show all components
kubectl get all -n ecommerce

# Show auto-scaling
kubectl get hpa -n ecommerce

# Test API
curl http://localhost:30080/api/products

# Show logs
kubectl logs -f deployment/api-gateway -n ecommerce

# Scale manually
kubectl scale deployment product-service --replicas=5 -n ecommerce
```

### For Project 2:
```bash
# Show registry
kubectl get all -n registry

# Push image
docker tag nginx localhost:30500/nginx
docker push localhost:30500/nginx

# View in UI
open http://localhost:30800

# Check backups
kubectl get cronjob -n registry
```

---

## Resume Bullet Points

### Project 1:
- Architected and deployed microservices e-commerce platform with 7 components on Kubernetes
- Implemented horizontal pod autoscaling (HPA) to handle 1000+ concurrent users
- Configured StatefulSets with persistent volumes for MongoDB data persistence
- Established service mesh networking with DNS-based service discovery
- Managed application configuration using ConfigMaps and Secrets

### Project 2:
- Designed and implemented secure private Docker registry with htpasswd authentication
- Reduced container image pull times by 70% using local registry infrastructure
- Automated daily backup system using Kubernetes CronJobs and persistent volumes
- Integrated TLS encryption for secure image transfer
- Deployed web-based UI for streamlined image management

---

## Practice Questions

1. Walk me through your Kubernetes project
2. How do you handle secrets in Kubernetes?
3. Explain your auto-scaling strategy
4. How do you ensure high availability?
5. What monitoring tools have you used?
6. How do you troubleshoot pod failures?
7. Explain your backup strategy
8. How do services communicate?
9. What's your deployment process?
10. How do you handle configuration changes?

---

**Practice explaining each component until you can do it without notes! 💪**
