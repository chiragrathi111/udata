How To Install Cilium (kubeadm Cluster)

🔹 Step 1 — Remove Existing CNI

* kubectl delete -f flannel.yaml

🔹 Step 2 — Install Cilium CLI

* curl -LO https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz
tar xzvf cilium-linux-amd64.tar.gz
* sudo mv cilium /usr/local/bin

🔹 Step 3 — Install Cilium

* cilium install

🔹 Step 4 — Verify

* cilium status
* kubectl get pods -n kube-system


🟢 Advanced Mode (Replace kube-proxy)
* cilium install --kube-proxy-replacement=strict

🟢 If Using EKS
* helm repo add cilium https://helm.cilium.io/
* helm install cilium cilium/cilium --namespace kube-system

🧠 Important Requirement

Cilium requires:

Linux kernel 4.9+

eBPF support enabled

Modern OS (Ubuntu 20+, Amazon Linux 2)

🔥 Real Production Advantage

With Cilium:

No need for separate service mesh (sometimes)

Can apply L7 policies

Deep traffic visibility

Scalable networking

🎯 Simple Understanding

If:

Flannel = Basic road
Calico = Road + traffic police
Cilium = Smart AI highway with CCTV + security + monitoring

