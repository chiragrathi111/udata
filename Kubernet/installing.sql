Run master and worker/node server:-

* sudo su
* apt-get update
* sudo apt-get install apt-transport-https -y
* sudo apt install docker.io -y
* docker --version
* systemctl start docker
* systemctl enable docker
* sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

* sudo mkdir -p /etc/apt/keyrings

* curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
| sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

* echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
| sudo tee /etc/apt/sources.list.d/kubernetes.list

* sudo apt update

* sudo apt install -y kubelet kubeadm kubectl

* sudo apt-mark hold kubelet kubeadm kubectl

* kubectl version --client
kubeadm version

o/p :-
kubeadm version
Client Version: v1.29.15
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
kubeadm version: &version.Info{Major:"1", Minor:"29", GitVersion:"v1.29.15", GitCommit:"0d0f172cdf9fd42d6feee3467374b58d3e168df0", GitTreeState:"clean", BuildDate:"2025-03-11T17:46:36Z", GoVersion:"go1.23.6", Compiler:"gc", Platform:"linux/amd64"}

---------------------------
Master Node Commands:-
* kubeadm init

If above command not working then run below commands:-

🔹 STEP 1: Disable swap (MANDATORY)

* swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

* free -h
o/p swap must be 0

🔹 STEP 2: Load required kernel modules

* modprobe overlay
modprobe br_netfilter

* cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

🔹 STEP 3: Set required sysctl parameters

* cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

* sysctl --system

🔹 STEP 4: VERIFY THE FILE EXISTS (IMPORTANT)

* ls /proc/sys/net/bridge/

o/p :-
bridge-nf-call-iptables
bridge-nf-call-ip6tables

🔹 STEP 5: RUN kubeadm init AGAIN

* kubeadm init --pod-network-cidr=10.244.0.0/16

below all three commands i got running above command ()
* mkdir -p $HOME/.kube
* sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

* chown $(id -u):$(id -g) $HOME/.kube/config

* kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml --validate=false

o/p:-

namespace/kube-flannel created
serviceaccount/flannel created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds created


-- * sudo kubectl apply -f //https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

-- * sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml

After that initiation time run init commands, so that commands paste both node
so our master and node both connected.

* kubectl get nodes (showingg all connected nodes)

Generally if gotting any error after running above commands then follow below code ow can resolve:-

# First edit one file and modify boolean value

* sudo nano /etc/containerd/config.toml
modify below line starting sowing false to replace true

systemd_cgroup = true
SystemdCgroup = true

then save that file.

* sudo systemctl restart containerd
sudo systemctl restart kubelet

after run that command wait 30-60 second

* sudo crictl info
 o/p You should see JSON output, NOT an error

* sudo crictl ps | egrep 'etcd|kube-apiserver|kube-scheduler'
o/p c3c41bb04e240 a9e7e6b294baf About a minute ago Running etcd 28 2401354551c55 etcd-chirag 
b09f150f9b2d0 9ea0bd82ed4f6 2 minutes ago Running kube-scheduler 31 62686572d53f8 kube-scheduler-chirag

* kubectl get nodes
o/p NAME STATUS ROLES AGE VERSION 
chirag Ready control-plane 113m v1.29.15
[ Directory '/etc/containerd' does not exist ]

aws master:-
-- kubeadm join 172.31.2.139:6443 --token vzoghk.mn53pjvcw3qmd3nw \
-- 	--discovery-token-ca-cert-hash sha256:ff3e02dedc47f42f3b08745c3b113b2e8b833cd54a3197f58afca706d6ddd6f9 

kubeadm join 172.31.2.139:6443 --token i1inct.ttsobmjbs68citjf \
	--discovery-token-ca-cert-hash sha256:608d79aa7dfad8baf4aacbc0cf82a9fd13229942a0934000b43092d7686fa8dc 



-------------------------------------------------------------------------------
Worker/Node Server:-
* sudo systemctl stop kubelet
sudo systemctl stop containerd

* sudo rm -f /etc/containerd/config.toml
If are you run any wrong way then first run above commands then run below commands

* sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

If every thing is fine ten run below commands

* sudo nano /etc/containerd/config.toml
Modify value
systemd_cgroup = true
SystemdCgroup = true

* sudo systemctl restart containerd

* sudo systemctl status containerd --no-pager
o/p:- Active: active (running)

* sudo systemctl restart kubelet


kubeadm join 192.168.1.52:6443 --token 76n521.56gh3vl36boglzb2 \
	--discovery-token-ca-cert-hash sha256:6dd8b0eafd40f8cbb29c1021b9cf298e9d38f71a71c0cb20ee8645596ab278cf

	Public IP:- 103.135.66.18

	kubeadm join 103.135.66.18:6443 --token 76n521.56gh3vl36boglzb2 \
	--discovery-token-ca-cert-hash sha256:6dd8b0eafd40f8cbb29c1021b9cf298e9d38f71a71c0cb20ee8645596ab278cf