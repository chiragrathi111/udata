# Node Affinity Complete Guide 🧲
## Advanced Pod Placement Rules

---

## What is Node Affinity? 🤔

**Node Affinity** = Advanced rules for pod placement on nodes

**vs Node Selector:**
- NodeSelector: Simple (disktype=ssd)
- Node Affinity: Complex (disktype=ssd OR disktype=nvme)

---

## Types 🎯

### 1. requiredDuringSchedulingIgnoredDuringExecution
**What:** MUST match (hard requirement)
**Use:** Critical placement rules

### 2. preferredDuringSchedulingIgnoredDuringExecution
**What:** TRY to match (soft preference)
**Use:** Nice-to-have placement

---

## Real-World Example: Zone Placement 🌍

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: zone
            operator: In
            values:
            - us-east-1a
            - us-east-1b
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
  containers:
  - name: webapp
    image: nginx
```

**What this does:**
- MUST run in us-east-1a or us-east-1b
- PREFER nodes with SSD

---

## Operators 🔧

- **In** - Value in list
- **NotIn** - Value not in list
- **Exists** - Key exists
- **DoesNotExist** - Key doesn't exist
- **Gt** - Greater than
- **Lt** - Less than

---

## Key Takeaways 🎯

1. **Node Affinity** = Advanced placement rules
2. **Required** = Must match
3. **Preferred** = Try to match
4. **Use for** = Complex scheduling needs

**Node Affinity = Smart Pod Placement! 🧲**
