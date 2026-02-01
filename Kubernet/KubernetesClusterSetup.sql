✅ Kubernetes Cluster Setup (kubeadm)

Version: v1.29
Platform: AWS EC2 (Ubuntu)
CNI: Flannel
Runtime: Docker + containerd

🧠 High-level Kubernetes flow (remember this)
OS Ready
 → Container Runtime (containerd)
 → kubelet (node agent)
 → kubeadm (cluster bootstrap)
 → Control Plane
 → CNI Network
 → Worker Join

🟦 MASTER SERVER NODE
🔹 1. Basic OS preparation
sudo su


➡ Switch to root user so all system-level configs work without permission issues.

apt-get update -y


➡ Refresh package index so system knows latest available packages.

apt-get install -y apt-transport-https ca-certificates curl gpg


➡ Required tools:

curl → download Kubernetes repo keys

gpg → verify repo security

ca-certificates → HTTPS trust

🔹 2. Install Docker (container runtime dependency)
apt install -y docker.io


➡ Installs Docker, which internally uses containerd (Kubernetes talks to containerd).

docker --version


➡ Verify Docker installed correctly.

systemctl start docker
systemctl enable docker


➡ Start Docker now + auto-start on reboot.

💡 Important: Kubernetes does NOT use Docker directly, it uses containerd underneath.

🔹 3. Install Kubernetes repo (v1.29 – stable)
mkdir -p /etc/apt/keyrings


➡ Secure location to store Kubernetes signing keys.

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
| gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg


➡ Download and trust Kubernetes official package signing key.

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
| tee /etc/apt/sources.list.d/kubernetes.list


➡ Add Kubernetes repo to apt sources (locked to v1.29).

🔹 4. Install kubeadm, kubelet, kubectl
apt update


➡ Refresh repo list including Kubernetes repo.

apt install -y kubelet kubeadm kubectl


➡ Install:

kubeadm → cluster bootstrap tool

kubelet → node agent (runs pods)

kubectl → cluster CLI

apt-mark hold kubelet kubeadm kubectl


➡ Prevent accidental version upgrade (very important for stability).

🔹 5. Disable swap (MANDATORY)
swapoff -a


➡ Kubernetes refuses to run with swap enabled.

sed -i '/ swap / s/^/#/' /etc/fstab


➡ Permanently disable swap after reboot.

🔹 6. Enable kernel networking modules
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF


➡ Required kernel modules:

overlay → container filesystem

br_netfilter → pod network traffic

modprobe overlay
modprobe br_netfilter


➡ Load modules immediately.

🔹 7. Sysctl settings (networking rules)
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF


➡ Allows:

Pod-to-pod traffic

Pod-to-service routing

Proper iptables handling

sysctl --system


➡ Apply kernel parameters now.

🔹 8. Fix containerd (🔥 MOST IMPORTANT STEP 🔥)
sudo mkdir -p /etc/containerd


➡ Create containerd config directory.

containerd config default > /etc/containerd/config.toml


➡ Generate default containerd config.

nano /etc/containerd/config.toml

🔴 Change:
SystemdCgroup = true


➡ Required because:

kubelet uses systemd

containerd must match kubelet cgroup driver

This fixes CRI errors you faced earlier

systemctl restart containerd
systemctl restart kubelet


➡ Apply new runtime config.

🔹 9. Initialize Kubernetes MASTER
kubeadm init --pod-network-cidr=10.244.0.0/16


➡ What this does:

Creates control plane

Starts API server, scheduler, controller

Generates certificates

Sets cluster CIDR for Flannel

📌 This command outputs the worker join command

🔹 10. Configure kubectl for normal user
mkdir -p $HOME/.kube


➡ Create kubeconfig directory for current user.

cp /etc/kubernetes/admin.conf $HOME/.kube/config


➡ Copy admin credentials.

chown $(id -u):$(id -g) $HOME/.kube/config


➡ Fix permission so kubectl works without sudo.

kubectl get nodes


➡ Output: NotReady
✅ Expected (network not installed yet)

🔹 11. Install Pod Network (Flannel)
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml


➡ Installs CNI:

Pod IP assignment

Pod-to-pod communication

⏳ Wait 1–2 minutes

kubectl get nodes


➡ Output: Ready
🎉 Master is fully operational

🟩 WORKER NODE

Worker setup is same as master except:
❌ NO kubeadm init
❌ NO kubectl config
❌ NO CNI install

Steps 1 → 8 are IDENTICAL
(Reason: workers also run kubelet + containerd)

🔹 9. Join worker to cluster
kubeadm join 172.31.2.139:6443 --token i1inct.ttsobmjbs68citjf \
--discovery-token-ca-cert-hash sha256:608d79aa7dfad8baf4aacbc0cf82a9fd13229942a0934000b43092d7686fa8dc


➡ What this does:

Connects worker to master

Registers node with API server

Starts kubelet on worker

📌 Token comes from kubeadm init

🟦 FINAL CHECK (ON MASTER)
sudo su
kubectl get nodes


➡ Output:

master   Ready   control-plane
worker   Ready   <none>


🎉 CLUSTER COMPLETE