✅ We are creating:

1 Master Node (Control Plane)
2 Worker Nodes
Using kubeadm
Container Runtime: containerd
CNI: Calico

✅ PHASE 1 — COMMON STEPS (Run on ALL nodes: Master + Workers)

1️⃣ Disable Swap

* swapoff -a
* sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

👉 Kubernetes does NOT work with swap enabled
👉 This permanently disables swap

* free -h (verify)

2️⃣ Enable Kernel Modules

* cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

* sudo modprobe overlay
* sudo modprobe br_netfilter

3️⃣ Configure Sysctl (Networking)

* cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

* sudo sysctl --system

Verify:

* sysctl net.bridge.bridge-nf-call-iptables
* sysctl net.ipv4.ip_forward

✅ PHASE 2 — Install Container Runtime (ALL NODES)

4️⃣ Install containerd

* curl -LO https://github.com/containerd/containerd/releases/download/v1.7.14/containerd-1.7.14-linux-amd64.tar.gz

* sudo tar Cxzvf /usr/local containerd-1.7.14-linux-amd64.tar.gz

* curl -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

* sudo mkdir -p /usr/local/lib/systemd/system/

* sudo mv containerd.service /usr/local/lib/systemd/system/

5️⃣ Configure containerd

* sudo mkdir -p /etc/containerd

* containerd config default | sudo tee /etc/containerd/config.toml

Enable SystemdCgroup:

* sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

Start service:-

* sudo systemctl daemon-reload
* sudo systemctl enable --now containerd

Verify:-
* systemctl status containerd

6️⃣ Install runc

* curl -LO https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64

* sudo install -m 755 runc.amd64 /usr/local/sbin/runc

7️⃣ Install CNI Plugins

* curl -LO https://github.com/containernetworking/plugins/releases/download/v1.5.0/cni-plugins-linux-amd64-v1.5.0.tgz

* sudo mkdir -p /opt/cni/bin

* sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.5.0.tgz

✅ PHASE 3 — Install Kubernetes Tools (ALL NODES)

* sudo apt-get update
* sudo apt-get install -y apt-transport-https ca-certificates curl gpg

Add Kubernet Repo:-

* sudo mkdir -p /etc/apt/keyrings

* curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

* echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# tf you have gotting error then first remove using below command and again run above code 
* sudo rm /etc/apt/sources.list.d/kubernetes.list

OR

Above two commands only change if you want move version 1.29 to 1.30

* curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

* echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' |
sudo tee /etc/apt/sources.list.d/kubernetes.list


Install version:-

* sudo apt-get update

* sudo apt-get install -y \
kubelet=1.29.6-1.1 \
kubeadm=1.29.6-1.1 \
kubectl=1.29.6-1.1 \
--allow-downgrades --allow-change-held-packages

OR

* sudo apt-get install -y kubelet=1.30.1-1.1 \
kubeadm=1.30.1-1.1 \
kubectl=1.30.1-1.1 \
--allow-downgrades --allow-change-held-packages


* sudo apt-mark hold kubelet kubeadm kubectl

* kubeadm version
* kubelet --version
* kubectl version --client

8️⃣ Configure crictl (ALL NODES)

* sudo crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock

✅ PHASE 4 — Initialize Master Node (ONLY MASTER)

* sudo kubeadm init \
--pod-network-cidr=192.168.0.0/16 \
--apiserver-advertise-address=<MASTER_PRIVATE_IP> \
--node-name master

9️⃣ Configure kubectl (MASTER ONLY)

* mkdir -p $HOME/.kube

* sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

* sudo chown $(id -u):$(id -g) $HOME/.kube/config

* kubectl get nodes

✅ PHASE 5 — Install Calico (MASTER ONLY)

* kubectl create -f \
https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml

* curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml -O

* kubectl apply -f custom-resources.yaml

Wait 1-2 mintues

* kubectl get pods -A


✅ PHASE 6 — Join Worker Nodes

* sudo kubeadm join <MASTER_IP>:6443 \
--token <TOKEN> \
--discovery-token-ca-cert-hash sha256:<HASH>

example:-
sudo kubeadm join 172.31.28.143:6443 --token mus22t.njducoiilxbhtmvi \
	--discovery-token-ca-cert-hash sha256:cfa65994013b8d635be8026e23ef348747f08004cddfe9c3586f51456e51ead2

Note:- This above commmands getting in master node side after run Initialize master node commands
        please using copy and paste, don't write because if you made any mistake then worker node not join

If you lose this above commands so run the below commands you getting new one

* kubeadm token create --print-join-command

✅ FINAL VALIDATION (MASTER)

After joining will check every thing is working fine or not

* kubectl get nodes

* kubectl get pods -A

✅ AWS IMPORTANT SETTINGS
✔ Allow these ports in Security Group:
Master:

# 6443

# 2379-2380

# 10250

# 10259

# 10257

# 179

# 4789 (Calico)

Workers:

# 10250

# 30000-32767

# 179

# 4789 (Calico)


🔥 If Calico Not Working

* ip a

Update:

* kubectl set env daemonset/calico-node -n calico-system \
IP_AUTODETECTION_METHOD=interface=ens5

Or install manifest version:

* kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
