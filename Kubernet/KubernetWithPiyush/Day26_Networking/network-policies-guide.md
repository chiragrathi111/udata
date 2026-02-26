# Network Policies Complete Guide 🔒
## Pod-Level Firewall

---

## What is Network Policy? 🤔

**Network Policy** = Firewall rules for pods

**Think of it like:**
- Building = Kubernetes cluster
- Rooms = Pods
- Doors = Network connections
- Network Policy = Security guard controlling who enters

---

## Why Use Network Policies? 💡

### Without Network Policy:
```
Any pod can talk to any pod ❌
Frontend can access database directly ❌
No network security ❌
```

### With Network Policy:
```
Only allowed pods can communicate ✅
Frontend → Backend → Database ✅
Network security enforced ✅
```

---

## Default Behavior 🎯

**By default:** All pods can talk to all pods

**After Network Policy:** Only allowed traffic permitted

---

## Network Policy Types 📊

### 1. Ingress (Incoming)
**Controls:** Who can connect TO this pod

### 2. Egress (Outgoing)
**Controls:** Where this pod can connect TO

---

## Basic Network Policy 📝

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: production
spec:
  podSelector: {}          # Apply to all pods
  policyTypes:
  - Ingress
  - Egress
```

**Result:** All pods isolated (no traffic allowed)

---

## Allow Specific Traffic 🚦

### Example 1: Allow Frontend → Backend

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend         # Apply to backend pods
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend    # Allow from frontend pods
    ports:
    - protocol: TCP
      port: 8080
```

**Result:**
- Backend pods accept traffic from frontend pods on port 8080
- All other traffic blocked

---

## Real-World Example: 3-Tier App 🏗️

```yaml
# 1. Database Policy (most restrictive)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: backend    # Only backend can access
    ports:
    - protocol: TCP
      port: 3306
---
# 2. Backend Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend   # Only frontend can access
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          tier: database   # Can only talk to database
    ports:
    - protocol: TCP
      port: 3306
  - to:                    # Allow DNS
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53
---
# 3. Frontend Policy (least restrictive)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: frontend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          tier: backend    # Can only talk to backend
    ports:
    - protocol: TCP
      port: 8080
  - to:                    # Allow DNS
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53
```

**Traffic Flow:**
```
User → Frontend → Backend → Database
       ✅         ✅        ✅

User → Database ❌ (blocked)
Frontend → Database ❌ (blocked)
```

---

## Namespace Isolation 🏢

```yaml
# Allow traffic only from same namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector: {}      # Same namespace only
```

---

## Allow from Specific Namespace 🎯

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-monitoring
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: webapp
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: 9090
```

---

## Allow External Traffic 🌐

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-external
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - ipBlock:
        cidr: 0.0.0.0/0    # Allow from anywhere
        except:
        - 10.0.0.0/8       # Except internal network
    ports:
    - protocol: TCP
      port: 80
```

---

## Egress Policy (Outgoing) 📤

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-external-api
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 443          # HTTPS only
  - to:                  # DNS
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
```

---

## Common Patterns 🎯

### Pattern 1: Deny All (Default Deny)
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### Pattern 2: Allow All (Default Allow)
```yaml
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
```

### Pattern 3: Allow DNS
```yaml
egress:
- to:
  - namespaceSelector:
      matchLabels:
        name: kube-system
  ports:
  - protocol: UDP
    port: 53
```

---

## Prerequisites 📋

**Network Policy requires CNI plugin support:**
- ✅ Calico
- ✅ Cilium
- ✅ Weave Net
- ❌ Flannel (doesn't support)

```bash
# Check if network policies work
kubectl get networkpolicies
```

---

## Commands 🔧

```bash
# Create network policy
kubectl apply -f network-policy.yaml

# Get network policies
kubectl get networkpolicies
kubectl get netpol

# Describe network policy
kubectl describe networkpolicy my-policy

# Delete network policy
kubectl delete networkpolicy my-policy

# Get in all namespaces
kubectl get networkpolicies -A
```

---

## Testing Network Policies 🧪

```bash
# Test connectivity
kubectl run test-pod --image=busybox -it --rm -- sh

# Inside pod, test connection
wget -O- http://backend-service:8080

# If blocked: timeout
# If allowed: response
```

---

## Best Practices 📚

### 1. Start with Deny All
```yaml
# First, deny everything
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### 2. Then Allow Specific Traffic
```yaml
# Then, allow what's needed
ingress:
- from:
  - podSelector:
      matchLabels:
        app: frontend
```

### 3. Always Allow DNS
```yaml
egress:
- to:
  - namespaceSelector: {}
  ports:
  - protocol: UDP
    port: 53
```

### 4. Use Labels Consistently
```yaml
# ✅ Good
matchLabels:
  app: backend
  tier: api

# ❌ Bad
matchLabels:
  name: backend-pod-123
```

---

## Troubleshooting 🔍

### Issue 1: Policy not working
```bash
# Check CNI plugin supports network policies
kubectl get pods -n kube-system | grep calico

# Check policy exists
kubectl get networkpolicy

# Check pod labels match
kubectl get pods --show-labels
```

### Issue 2: Can't connect to pods
```bash
# Check if network policy blocking
kubectl describe networkpolicy

# Test without network policy
kubectl delete networkpolicy my-policy
# Try connection again
```

---

## Key Takeaways 🎯

1. **Network Policy** = Pod firewall
2. **Default** = Allow all (no policies)
3. **After policy** = Only allowed traffic
4. **Ingress** = Incoming traffic
5. **Egress** = Outgoing traffic
6. **Requires** = CNI plugin support

**Network Policies = Pod-Level Security! 🔒**
