# Check pod status
kubectl get pods --all-namespaces -o wide | grep -E '(api|etcd|calico|kube-scheduler|kube-controller)'

# Check logs for errors
kubectl logs -n kube-system <apiserver-pod-name>
kubectl logs -n kube-system <etcd-pod-name>
kubectl logs -n calico-system <calico-node-pod>

# Check node conditions
kubectl describe nodes

# Check if certificates are valid
sudo kubeadm certs check-expiration

# If API server is completely down, check static pod manifests
ls /etc/kubernetes/manifests/
cat /etc/kubernetes/manifests/kube-apiserver.yaml


sudo systemctl status kubelet
sudo journalctl -xeu kubelet -f

sudo crictl ps
sudo crictl images | grep kube

# Check etcd member list
sudo etcdctl member list --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key


# Check if Calico version is compatible with Kubernetes 1.30
kubectl get deployment -n calico-system calico-kube-controllers -o yaml | grep image
# You may need to update Calico