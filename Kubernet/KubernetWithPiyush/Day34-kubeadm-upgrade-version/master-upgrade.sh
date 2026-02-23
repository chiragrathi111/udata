# MASTER NODE UPGRADE

# 1. First, BACKUP etcd (CRITICAL!)
sudo etcdctl snapshot save /var/lib/etcd-snapshot.db
# Or if using kubeadm etcd:
sudo cp -r /var/lib/etcd /var/lib/etcd-backup

# 2. Update Kubernetes repository (if needed)
sudo nano /etc/apt/sources.list.d/kubernetes.list
# Ensure it points to correct version repo

# 3. Update package list
sudo apt-get update

# 4. Check available versions
sudo apt-cache madison kubeadm

# 5. Upgrade kubeadm (correct version format)
sudo apt-mark unhold kubeadm && \
sudo apt-get update && \
sudo apt-get install -y kubeadm=1.30.2-* && \
sudo apt-mark hold kubeadm

# 6. Verify kubeadm version
kubeadm version

# 7. Check upgrade plan
sudo kubeadm upgrade plan

# 8. Drain the master node PROPERLY
kubectl cordon master
kubectl drain master --ignore-daemonsets --delete-emptydir-data

# 9. Apply the upgrade
sudo kubeadm upgrade apply v1.30.2

# 10. Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && \
sudo apt-get install -y kubelet=1.30.2-* kubectl=1.30.2-* && \
sudo apt-mark hold kubelet kubectl

# 11. Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# 12. Verify node status
kubectl get nodes
kubectl uncordon master

# 13. Verify all system pods are running
kubectl get pods -n kube-system
kubectl get pods -n calico-system  # if using Calico

# 14. Check component statuses
kubectl get componentstatuses