* Master Server Node:-
🔹 1. Basic OS preparation

sudo su
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl gpg


🔹 2. Install Docker (container runtime dependency)

apt install -y docker.io
docker --version
systemctl start docker
systemctl enable docker


🔹 3. Install Kubernetes repo (v1.29 – stable)

mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
| gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
| tee /etc/apt/sources.list.d/kubernetes.list


🔹 4. Install kubeadm, kubelet, kubectl

apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl


🔹 5. Disable swap (MANDATORY)

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab


🔹 6. Enable kernel networking

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

🔹 7. Sysctl settings

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

🔹 8. Fix containerd (MOST IMPORTANT)

sudo mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
nano /etc/containerd/config.toml


🔴 Change this line:

SystemdCgroup = true


systemctl restart containerd
systemctl restart kubelet


🔹 9. Initialize Kubernetes MASTER

kubeadm init --pod-network-cidr=10.244.0.0/16

o/p :- Your Kubernetes control-plane has initialized successfully!


🔹 10. Configure kubectl for normal user

This below three line come to run thhat commands

mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

Test:-

kubectl get nodes

o/p NotReady

🔹 11. Install Pod Network (Flannel)

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

Wait 60-120 seconds

kubectl get nodes

o/p Ready

# Master Server Done

---------------------------------------------------------------------------------------
* Worker Node:-

🔹 1. Basic OS preparation

sudo su
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl gpg


🔹 2. Install Docker (container runtime dependency)

apt install -y docker.io
docker --version
systemctl start docker
systemctl enable docker


🔹 3. Install Kubernetes repo (v1.29 – stable)

mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
| gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
| tee /etc/apt/sources.list.d/kubernetes.list


🔹 4. Install kubeadm, kubelet, kubectl

apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl


🔹 5. Disable swap (MANDATORY)

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab


🔹 6. Enable kernel networking

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

🔹 7. Sysctl settings

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

🔹 8. Fix containerd (MOST IMPORTANT)

sudo mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
nano /etc/containerd/config.toml


🔴 Change this line:

SystemdCgroup = true


systemctl restart containerd
systemctl restart kubelet

🔹 9. Join worker to cluster

kubeadm join 172.31.2.139:6443 --token i1inct.ttsobmjbs68citjf \
	--discovery-token-ca-cert-hash sha256:608d79aa7dfad8baf4aacbc0cf82a9fd13229942a0934000b43092d7686fa8dc 

This code come after run <kubeadm init --pod-network-cidr=10.244.0.0/16>
so gotting that above commands	

=========================================================================
# Master Server:-

After setup worker node then run below commands on master server:-

sudo su

kubectl get nodes


