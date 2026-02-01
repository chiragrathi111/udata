🔹 1. Basic OS prep

sudo apt update
sudo apt install -y curl wget apt-transport-https

🔹 2. Install Docker (Minikube driver)

sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
docker --version

🔸 Allow normal user to run docker (IMPORTANT)

sudo usermod -aG docker $USER
newgrp docker
docker ps 

🔹 3. Install kubectl (official binary)

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"  (Taking time Dont panic)
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

🔹 4. Install Minikube

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube
minikube version

🔹 5. Start Minikube (THIS is the key command)

minikube start --driver=docker

🔹 6. Verify cluster

kubectl get nodes

o/p

NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   XXs   v1.xx.x

🔹 7. Basic health checks

kubectl get pods -A

🔹 8. Enable common addons (optional but useful)

minikube addons enable dashboard
minikube addons enable ingress

Open dashboard:
minikube dashboard


-----------------------------------------------------------
🥈 OPTION B: none driver (root-only, NOT recommended)

🔹 1. Install missing dependencies

sudo apt update
sudo apt install -y conntrack socat

🔹 2. Start Minikube as root

sudo minikube start --driver=none

🔹 3. Fix kubeconfig permission

sudo chown -R ubuntu:ubuntu /root/.kube /root/.minikube

🔹 4. Verify

kubectl get nodes

