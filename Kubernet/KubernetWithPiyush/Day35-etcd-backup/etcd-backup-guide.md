# ETCD Backup & Restore Guide 💾
## Disaster Recovery

---

## What is ETCD? 🤔

**ETCD** = Database storing all Kubernetes cluster data

**Stores:**
- Pods, Services, Deployments
- ConfigMaps, Secrets
- RBAC rules
- Everything!

**If ETCD lost = Cluster lost ❌**

---

## Why Backup ETCD? 💡

### Without Backup:
```
ETCD crashes → All data lost → Cluster gone ❌
Need to rebuild everything from scratch
```

### With Backup:
```
ETCD crashes → Restore from backup → Cluster back ✅
Minutes to recover
```

---

## Taking Backup 📸

```bash
# Install etcdctl
apt-get install etcd-client

# Set API version
export ETCDCTL_API=3

# Take snapshot
etcdctl snapshot save /backup/etcd-snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Verify snapshot
etcdctl snapshot status /backup/etcd-snapshot.db
```

---

## Automated Backup 🤖

```bash
# Create backup script
cat > /usr/local/bin/etcd-backup.sh <<'EOF'
#!/bin/bash
BACKUP_DIR="/backup/etcd"
DATE=$(date +%Y%m%d-%H%M%S)

mkdir -p $BACKUP_DIR

ETCDCTL_API=3 etcdctl snapshot save \
  $BACKUP_DIR/etcd-snapshot-$DATE.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Keep only last 7 days
find $BACKUP_DIR -name "etcd-snapshot-*.db" -mtime +7 -delete

echo "Backup completed: etcd-snapshot-$DATE.db"
EOF

chmod +x /usr/local/bin/etcd-backup.sh

# Add to crontab (daily at 2 AM)
crontab -e
0 2 * * * /usr/local/bin/etcd-backup.sh
```

---

## Restoring Backup 🔄

```bash
# 1. Stop API server
mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/

# 2. Restore snapshot
ETCDCTL_API=3 etcdctl snapshot restore /backup/etcd-snapshot.db \
  --data-dir=/var/lib/etcd-restore \
  --initial-cluster=master=https://127.0.0.1:2380 \
  --initial-advertise-peer-urls=https://127.0.0.1:2380

# 3. Update ETCD manifest
vi /etc/kubernetes/manifests/etcd.yaml
# Change: --data-dir=/var/lib/etcd-restore

# 4. Start API server
mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/

# 5. Verify
kubectl get nodes
kubectl get pods -A
```

---

## Backup to Remote Storage ☁️

```bash
# Backup to S3
etcdctl snapshot save /tmp/etcd-snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

aws s3 cp /tmp/etcd-snapshot.db s3://my-bucket/etcd-backups/

# Restore from S3
aws s3 cp s3://my-bucket/etcd-backups/etcd-snapshot.db /tmp/
etcdctl snapshot restore /tmp/etcd-snapshot.db
```

---

## Backup Verification ✅

```bash
# Check snapshot status
etcdctl snapshot status /backup/etcd-snapshot.db --write-out=table

# Output:
# +----------+----------+------------+------------+
# |   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
# +----------+----------+------------+------------+
# | 12345678 |   123456 |       1234 |     10 MB  |
# +----------+----------+------------+------------+
```

---

## Best Practices 📚

### 1. Backup Regularly
```bash
# Daily backups minimum
# Hourly for critical clusters
0 * * * * /usr/local/bin/etcd-backup.sh
```

### 2. Store Backups Off-Cluster
```bash
# S3, GCS, Azure Blob
# Not on same server!
```

### 3. Test Restores
```bash
# Test restore in dev cluster
# Verify data integrity
```

### 4. Keep Multiple Backups
```bash
# Last 7 days minimum
# Last 30 days for production
```

### 5. Monitor Backup Success
```bash
# Alert if backup fails
# Check backup size
```

---

## Disaster Recovery Plan 🚨

```
1. Detect ETCD failure
   ↓
2. Get latest backup
   ↓
3. Stop API server
   ↓
4. Restore ETCD
   ↓
5. Start API server
   ↓
6. Verify cluster
   ↓
7. Resume operations
```

---

## Key Takeaways 🎯

1. **ETCD** = Cluster brain
2. **Backup daily** = Minimum
3. **Store off-cluster** = S3, GCS
4. **Test restores** = Regularly
5. **Automate** = Cron job

**ETCD Backup = Disaster Recovery! 💾**
