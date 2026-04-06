# Kubernetes Commands - Beginner Level 🟢
## From Zero to Comfortable - Every Command You Need

---

## Shortcut if you wany move namespaces or cluster

```bash

# Cluster 
kubectx   # show all cluster name
# If is it not install run below commands
sudo apt  install kubectx -y
kubectx <CLUSTER_NAME>

OLD
kubectl config use-context production-cluster

# Namespace
kubens  # show all Namespace
kubens <NAMESPACES_NAME>

OLD 
kubectl config set-context --current --namespace=web-app
```

## Finding apiVersion and kind :-

```bash
kubectl api-resources
kubectl api-resources | grep <KIND_NAME>

kubectl explain <RESOURCE_NAME>
kubectl explain Gateway

# FORMAT
# NAME | SHORTNAMES | APIVERSION | NAMESPACED | KIND
```

## 1. CLUSTER INFO & SETUP 🏗️

```bash
# Check kubectl is installed
kubectl version
kubectl version --client

# Check cluster info
kubectl cluster-info

# Check cluster health
kubectl get componentstatuses
# OR short form
kubectl get cs

# View kubeconfig
kubectl config view

# Check current context (which cluster you're connected to)
kubectl config current-context

# List all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context <context-name>

# Set default namespace (so you don't type -n every time)
kubectl config set-context --current --namespace=<namespace>
```

---

## 2. NODES 🖥️

```bash
# List all nodes
kubectl get nodes

# Short form
kubectl get no

# Detailed node info
kubectl get nodes -o wide
# Shows: IP address, OS, kernel version, container runtime

# Describe specific node (full details + events)
kubectl describe node <node-name>

# Check node resource usage (needs metrics-server)
kubectl top nodes

# Get node labels
kubectl get nodes --show-labels

# Show specific label column
kubectl get nodes -L disktype

# Add label to node
kubectl label nodes <node-name> disktype=ssd

# Update existing label
kubectl label nodes <node-name> disktype=hdd --overwrite

# Remove label from node
kubectl label nodes <node-name> disktype-
# Note: minus (-) at end removes the label
```

---

## 3. PODS 🫛

### Create Pods

```bash
# Run a pod (simplest way)
kubectl run nginx --image=nginx

# Run pod and expose port
kubectl run nginx --image=nginx --port=80

# Run pod with labels
kubectl run nginx --image=nginx --labels="app=web,env=prod"

# Run pod in specific namespace
kubectl run nginx --image=nginx -n my-namespace

# Dry run - see YAML without creating
kubectl run nginx --image=nginx --dry-run=client -o yaml

# Generate YAML file
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml

# Create from YAML file
kubectl apply -f pod.yaml

# Create from URL
kubectl apply -f https://example.com/pod.yaml
```

### View Pods

```bash
# List pods in current namespace
kubectl get pods

# Short form
kubectl get po

# Detailed view
kubectl get pods -o wide
# Shows: Node, IP, Nominated Node, Readiness Gates

# List pods in ALL namespaces
kubectl get pods -A
# OR
kubectl get pods --all-namespaces

# List pods in specific namespace
kubectl get pods -n kube-system

# Watch pods in real-time (auto refresh)
kubectl get pods -w
kubectl get pods --watch

# Show pod labels
kubectl get pods --show-labels

# Filter pods by label
kubectl get pods -l app=nginx
kubectl get pods -l app=nginx,env=prod
kubectl get pods -l 'app in (nginx,apache)'
kubectl get pods -l 'app!=nginx'

# Sort pods by creation time
kubectl get pods --sort-by=.metadata.creationTimestamp

# Sort pods by restart count
kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'

# Get pod YAML
kubectl get pod nginx -o yaml

# Get pod JSON
kubectl get pod nginx -o json

# Get only pod names
kubectl get pods -o name

# Custom columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,IP:.status.podIP
```

### Describe & Debug Pods

```bash
# Full details of a pod (events, conditions, volumes)
kubectl describe pod nginx
# This is your BEST FRIEND for debugging!
# Check "Events" section at bottom for errors

# View pod logs
kubectl logs nginx

# View logs of specific container (multi-container pod)
kubectl logs nginx -c sidecar-container

# Follow logs in real-time (like tail -f)
kubectl logs -f nginx

# View last 50 lines
kubectl logs --tail=50 nginx

# View logs from last 1 hour
kubectl logs --since=1h nginx

# View logs from last 5 minutes
kubectl logs --since=5m nginx

# View previous container logs (if pod restarted)
kubectl logs nginx --previous
# OR
kubectl logs nginx -p
```

### Execute Commands Inside Pod

```bash
# Open shell inside pod
kubectl exec -it nginx -- /bin/bash

# If bash not available (alpine images)
kubectl exec -it nginx -- /bin/sh

# Run single command
kubectl exec nginx -- ls /usr/share/nginx/html

# Run command in specific container
kubectl exec -it nginx -c sidecar -- /bin/sh

# Check environment variables inside pod
kubectl exec nginx -- env

# Check DNS resolution inside pod
kubectl exec nginx -- nslookup kubernetes

# Check network connectivity
kubectl exec nginx -- curl http://some-service:80
```

### Edit & Delete Pods

```bash
# Edit pod (opens in vi editor)
kubectl edit pod nginx

# Delete pod
kubectl delete pod nginx

# Delete pod immediately (no grace period)
kubectl delete pod nginx --grace-period=0 --force

# Delete all pods in namespace
kubectl delete pods --all

# Delete pods by label
kubectl delete pods -l app=nginx

# Delete from YAML file
kubectl delete -f pod.yaml
```

---

## 4. DEPLOYMENTS 📦

### Create Deployments

```bash
# Create deployment
kubectl create deployment nginx-deploy --image=nginx

# Create with replicas
kubectl create deployment nginx-deploy --image=nginx --replicas=3

# Create with port
kubectl create deployment nginx-deploy --image=nginx --port=80

# Generate YAML
kubectl create deployment nginx-deploy --image=nginx --dry-run=client -o yaml > deploy.yaml

# Apply from file
kubectl apply -f deploy.yaml
```

### View Deployments

```bash
# List deployments
kubectl get deployments
# Short form
kubectl get deploy

# Detailed view
kubectl get deploy -o wide

# Describe deployment
kubectl describe deployment nginx-deploy

# Check rollout status
kubectl rollout status deployment nginx-deploy

# View rollout history
kubectl rollout history deployment nginx-deploy

# View specific revision
kubectl rollout history deployment nginx-deploy --revision=2
```

### Update Deployments

```bash
# Update image
kubectl set image deployment/nginx-deploy nginx=nginx:1.25

# Scale replicas
kubectl scale deployment nginx-deploy --replicas=5

# Edit deployment
kubectl edit deployment nginx-deploy

# Add annotation for change cause
kubectl annotate deployment nginx-deploy kubernetes.io/change-cause="updated to v1.25"
```

### Rollback Deployments

```bash
# Rollback to previous version
kubectl rollout undo deployment nginx-deploy

# Rollback to specific revision
kubectl rollout undo deployment nginx-deploy --to-revision=2

# Pause rollout (for making multiple changes)
kubectl rollout pause deployment nginx-deploy

# Resume rollout
kubectl rollout resume deployment nginx-deploy

# Restart all pods in deployment
kubectl rollout restart deployment nginx-deploy
```

### Delete Deployments

```bash
# Delete deployment
kubectl delete deployment nginx-deploy

# Delete from file
kubectl delete -f deploy.yaml
```

---

## 5. REPLICASETS 🔄

```bash
# List replicasets
kubectl get replicasets
# Short form
kubectl get rs

# Describe replicaset
kubectl describe rs <rs-name>

# Scale replicaset
kubectl scale rs <rs-name> --replicas=5

# Delete replicaset
kubectl delete rs <rs-name>
```
**Note:** Usually you don't create ReplicaSets directly. Deployments manage them automatically.

---

## 6. SERVICES 🌐

### Create Services

```bash
# Expose deployment as ClusterIP (internal only)
kubectl expose deployment nginx-deploy --port=80 --target-port=80

# Expose as NodePort (accessible from outside)
kubectl expose deployment nginx-deploy --type=NodePort --port=80 --target-port=80

# Expose as LoadBalancer (cloud only)
kubectl expose deployment nginx-deploy --type=LoadBalancer --port=80 --target-port=80

# Expose with specific name
kubectl expose deployment nginx-deploy --name=nginx-svc --port=80

# Expose pod directly
kubectl expose pod nginx --port=80 --name=nginx-svc

# Generate YAML
kubectl expose deployment nginx-deploy --port=80 --dry-run=client -o yaml > svc.yaml
```

### View Services

```bash
# List services
kubectl get services
# Short form
kubectl get svc

# Detailed view
kubectl get svc -o wide

# Describe service
kubectl describe svc nginx-svc

# Check endpoints (which pods are behind the service)
kubectl get endpoints
# Short form
kubectl get ep
```

### Delete Services

```bash
kubectl delete svc nginx-svc
```

### Service Types Explained:
```
ClusterIP  → Internal only (default). Pods talk to each other.
NodePort   → External access via NodeIP:NodePort (30000-32767)
LoadBalancer → Cloud provider gives external IP
ExternalName → Maps to external DNS name
```

---

## 7. NAMESPACES 📁

```bash
# List namespaces
kubectl get namespaces
# Short form
kubectl get ns

# Create namespace
kubectl create namespace dev

# Create from YAML
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: dev
EOF

# Get resources in specific namespace
kubectl get pods -n dev
kubectl get all -n dev

# Get resources in ALL namespaces
kubectl get pods -A

# Set default namespace
kubectl config set-context --current --namespace=dev

# Delete namespace (deletes EVERYTHING inside!)
kubectl delete namespace dev
```

### Default Namespaces:
```
default          → Your pods go here by default
kube-system      → Kubernetes system components
kube-public      → Publicly accessible data
kube-node-lease  → Node heartbeat data
```

---

## 8. CONFIGMAPS 📋

```bash
# Create from literal values
kubectl create configmap app-config --from-literal=DB_HOST=mysql --from-literal=DB_PORT=3306

# Create from file
kubectl create configmap app-config --from-file=config.properties

# Create from env file
kubectl create configmap app-config --from-env-file=.env

# View configmaps
kubectl get configmaps
# Short form
kubectl get cm

# Describe configmap
kubectl describe cm app-config

# View configmap data
kubectl get cm app-config -o yaml

# Edit configmap
kubectl edit cm app-config

# Delete configmap
kubectl delete cm app-config
```

---

## 9. SECRETS 🔐

```bash
# Create generic secret
kubectl create secret generic db-secret --from-literal=username=admin --from-literal=password=pass123

# Create from file
kubectl create secret generic tls-secret --from-file=cert.pem --from-file=key.pem

# Create docker registry secret
kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=myuser \
  --docker-password=mypass \
  --docker-email=my@email.com

# Create TLS secret
kubectl create secret tls my-tls --cert=tls.crt --key=tls.key

# View secrets
kubectl get secrets

# Describe secret (values hidden)
kubectl describe secret db-secret

# View secret with encoded values
kubectl get secret db-secret -o yaml

# Decode secret value
kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 --decode

# Delete secret
kubectl delete secret db-secret
```

---

## 10. APPLY, CREATE, REPLACE ⚡

```bash
# apply = Create or Update (RECOMMENDED)
kubectl apply -f file.yaml
# If resource doesn't exist → creates it
# If resource exists → updates it

# create = Only Create (fails if exists)
kubectl create -f file.yaml

# replace = Only Update (fails if doesn't exist)
kubectl replace -f file.yaml

# Apply all files in directory
kubectl apply -f ./kubernetes/

# Apply recursively
kubectl apply -f ./kubernetes/ -R

# Delete using file
kubectl delete -f file.yaml
```

### When to use what?
```
kubectl apply  → 99% of the time (safe, idempotent)
kubectl create → First time creation, generating resources
kubectl replace → Force update (replaces entire resource)
```

---

## 11. GET ALL RESOURCES 📊

```bash
# Get everything in current namespace
kubectl get all

# Get everything in all namespaces
kubectl get all -A

# Get specific resource types
kubectl get pods,svc,deploy

# Get with labels
kubectl get all -l app=nginx

# Output formats
kubectl get pods -o wide          # Extra columns
kubectl get pods -o yaml          # Full YAML
kubectl get pods -o json          # Full JSON
kubectl get pods -o name          # Only names
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase
```

---

## 12. LABELS & ANNOTATIONS 🏷️

### Labels (used for selection/filtering)

```bash
# Add label to pod
kubectl label pod nginx app=web

# Add label to node
kubectl label node node1 disktype=ssd

# Update label
kubectl label pod nginx app=api --overwrite

# Remove label
kubectl label pod nginx app-

# Filter by label
kubectl get pods -l app=web
kubectl get pods -l 'app in (web,api)'
kubectl get pods -l app!=web
kubectl get pods -l 'app,env'          # Has both labels

# Show labels
kubectl get pods --show-labels
```

### Annotations (metadata, not for selection)

```bash
# Add annotation
kubectl annotate pod nginx description="my web server"

# Update annotation
kubectl annotate pod nginx description="updated" --overwrite

# Remove annotation
kubectl annotate pod nginx description-

# View annotations
kubectl describe pod nginx | grep -A 5 Annotations
```

---

## 13. PORT FORWARDING 🔌

```bash
# Forward pod port to localhost
kubectl port-forward pod/nginx 8080:80
# Now visit: http://localhost:8080

# Forward service port
kubectl port-forward svc/nginx-svc 8080:80

# Forward deployment port
kubectl port-forward deployment/nginx-deploy 8080:80

# Forward to all interfaces (not just localhost)
kubectl port-forward --address 0.0.0.0 pod/nginx 8080:80

# Background port-forward
kubectl port-forward pod/nginx 8080:80 &
```

---

## 14. COPY FILES 📁

```bash
# Copy file from local to pod
kubectl cp ./local-file.txt nginx:/tmp/file.txt

# Copy file from pod to local
kubectl cp nginx:/tmp/file.txt ./local-file.txt

# Copy from specific container
kubectl cp nginx:/tmp/file.txt ./file.txt -c container-name

# Copy directory
kubectl cp ./local-dir nginx:/tmp/dir
```

---

## 15. RESOURCE USAGE 📈

```bash
# Pod resource usage (needs metrics-server)
kubectl top pods

# Pod usage in all namespaces
kubectl top pods -A

# Sort by CPU
kubectl top pods --sort-by=cpu

# Sort by memory
kubectl top pods --sort-by=memory

# Node resource usage
kubectl top nodes

# Specific pod containers
kubectl top pod nginx --containers
```

---

## 16. EVENTS 📰

```bash
# View events in current namespace
kubectl get events

# Sort by time
kubectl get events --sort-by=.metadata.creationTimestamp

# Watch events in real-time
kubectl get events -w

# Events in all namespaces
kubectl get events -A

# Filter warning events
kubectl get events --field-selector type=Warning
```

---

## 17. API RESOURCES 📚

```bash
# List all resource types
kubectl api-resources

# List with short names
kubectl api-resources -o name

# List namespaced resources only
kubectl api-resources --namespaced=true

# List cluster-scoped resources
kubectl api-resources --namespaced=false

# Explain a resource (documentation)
kubectl explain pod
kubectl explain pod.spec
kubectl explain pod.spec.containers
kubectl explain pod.spec.containers.resources
kubectl explain deployment.spec.strategy
# This is like built-in documentation!
```

---

## 18. QUICK SHORTCUTS ⚡

### Short Names (save typing):

```
po    = pods
svc   = services
deploy = deployments
rs    = replicasets
ds    = daemonsets
sts   = statefulsets
cm    = configmaps
ns    = namespaces
no    = nodes
pv    = persistentvolumes
pvc   = persistentvolumeclaims
sa    = serviceaccounts
ing   = ingress
ep    = endpoints
hpa   = horizontalpodautoscalers
```

### Bash Alias (add to ~/.bashrc):

```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias ke='kubectl exec -it'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'

# After adding, run:
source ~/.bashrc
```

### Auto-completion (MUST HAVE):

```bash
# Bash
source <(kubectl completion bash)
echo 'source <(kubectl completion bash)' >> ~/.bashrc

# Zsh
source <(kubectl completion zsh)
echo 'source <(kubectl completion zsh)' >> ~/.zshrc

# With alias
complete -o default -F __start_kubectl k
```

## Check and delete all records any specific namespace

```bash
kubectl get all -n <NAMESPACE_NAME>
kubectl delete all --all -n <NAMESPACE_NAME>
kubectl delete all --all -n web-app  # Pods,Service,Deployments,
kubectl delete pod --all -n web-app
```

---

## 19. HELP & DOCUMENTATION 📖

```bash
# General help
kubectl --help

# Help for specific command
kubectl get --help
kubectl run --help
kubectl create --help
kubectl apply --help

# Explain resource fields
kubectl explain pod
kubectl explain pod.spec
kubectl explain pod.spec.containers
kubectl explain pod --recursive    # Show ALL fields

# API versions
kubectl api-versions

# Check what you can do
kubectl auth can-i create pods
kubectl auth can-i delete deployments
kubectl auth can-i '*' '*'    # Am I admin?
```

---

## 🎯 Beginner Checklist

After learning these commands, you should be able to:

- [ ] Check cluster and node status
- [ ] Create, view, describe, delete pods
- [ ] View pod logs and exec into pods
- [ ] Create and manage deployments
- [ ] Scale and rollback deployments
- [ ] Create and manage services
- [ ] Work with namespaces
- [ ] Create ConfigMaps and Secrets
- [ ] Use labels and selectors
- [ ] Port-forward for testing
- [ ] Check resource usage
- [ ] Use short names and aliases

---

**Master these first, then move to Advanced! 💪**
