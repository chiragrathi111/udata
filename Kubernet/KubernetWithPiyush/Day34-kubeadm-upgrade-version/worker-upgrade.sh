# 1. Update Kubernetes repository (if needed)
sudo nano /etc/apt/sources.list.d/kubernetes.list

# WORKER NODE UPGRADE

# 1. Update repository and kubeadm on worker
sudo apt-get update
sudo apt-mark unhold kubeadm && \
sudo apt-get update && \
sudo apt-get install -y kubeadm=1.30.2-* && \
sudo apt-mark hold kubeadm

# 2. Verify kubeadm version
kubeadm version

# 3. Drain the worker node (run from master or with kubectl configured)
# First, from a machine with kubectl access:
kubectl cordon <worker-node-name>
kubectl drain <worker-node-name> --ignore-daemonsets --delete-emptydir-data

# 4. On the worker node, upgrade node configuration
sudo kubeadm upgrade node

# 5. Upgrade kubelet and kubectl on worker
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && \
sudo apt-get install -y kubelet=1.30.2-* kubectl=1.30.2-* && \
sudo apt-mark hold kubelet kubectl

# 6. Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# 7. Verify kubelet is running
sudo systemctl status kubelet

# 8. Uncordon the node (run from master)
kubectl uncordon <worker-node-name>

# 9. Verify node is ready
kubectl get nodes