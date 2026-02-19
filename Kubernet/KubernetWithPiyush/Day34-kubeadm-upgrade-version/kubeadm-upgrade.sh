#first update the existing file

# Master Node:-
* login master node

* sudo nano /etc/apt/sources.list.d/kubernetes.list
(upadetd the verion)

* sudo apt update

* sudo apt-cache madison kubeadm

* sudo apt-mark unhold kubeadm && \
sudo apt-get update && \
sudo apt update && sudo apt-get install -y kubeadm=1.30.2-1.1 && \
sudo apt-mark hold kubeadm

* sudo kubeadm upgrade plan

* sudo kubeadm upgrade apply v1.30.2 -y

* kubectl get node (old versions)

* kubectl drain master (error)

* kubectl drain master --ignore-daemonsets

* kubectl get node (see the version, observe master node)

* sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && \
sudo apt update && sudo apt-get install -y kubelet=1.30.2-1.1 kubectl=1.30.2-1.1 && \
sudo apt-mark hold kubelet kubectl

* sudo systemctl daemon-reload

* sudo systemctl restart kubelet

* kubectl get node

* sudo systemctl status kubelet

* kubectl get node (Status not change on the master node, but version updated)

*  kubectl version

* kubectl uncordon master

* kubectl get node (observe the version, master node is ready)


#Worker Node:-

* login worknode

* sudo nano /etc/apt/sources.list.d/kubernetes.list
(upadetd the verion)

* sudo apt update

* sudo apt-cache madison kubeadm

* sudo apt-mark unhold kubeadm && \
sudo apt-get update && \
sudo apt update && sudo apt-get install -y kubeadm=1.30.2-1.1 && \
sudo apt-mark hold kubeadm

* sudo kubeadm upgrade node

* kubectl get node (old versions)

* kubectl drain worker-node-name --ignore-daemonsets

* kubectl get node (see the version, observe worker node)

* sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && \
sudo apt update && sudo apt-get install -y kubelet=1.30.2-1.1 kubectl=1.30.2-1.1 && \
sudo apt-mark hold kubelet kubectl

* sudo systemctl daemon-reload

* sudo systemctl restart kubelet

* kubectl get node

* sudo systemctl status kubelet

* kubectl uncordon <worker-node-name>

* kubectl get node (observe the version, worker node is ready)

---------------------------------------------
That is flow:-

Drain
upgrade
uncordon
