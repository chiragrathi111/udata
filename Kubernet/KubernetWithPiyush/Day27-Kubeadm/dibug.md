# Check control plane pod health
kubectl get pods -n kube-system

# Check etcd specifically
kubectl logs etcd-master -n kube-system | tail -30

# Check API server logs
kubectl logs kube-apiserver-master -n kube-system | tail -30

# Check controller manager
kubectl logs kube-controller-manager-master -n kube-system | tail -30

# Check Calico node status
kubectl get pods -n calico-system
kubectl logs -n calico-system daemonset/calico-node | tail -50

# Check kubelet on any failing node
sudo journalctl -u kubelet -n 100 --no-pager

# Verify cgroup driver agreement
sudo crictl info | grep cgroup
cat /var/lib/kubelet/config.yaml | grep cgroup