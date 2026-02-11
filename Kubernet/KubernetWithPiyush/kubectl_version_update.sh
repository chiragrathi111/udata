#!/bin/bash

# ==============================
# Kubernetes Upgrade Checklist
# ==============================

# 🔹 STEP 1: Check cluster health
echo "Checking cluster health..."
kubectl get nodes
kubectl get pods -A

# 🔹 STEP 2: Check current kubectl version
echo "Current kubectl version:"
kubectl version --client

# 🔹 STEP 3: Set required Kubernetes version
K8S_VERSION="v1.30.0"

echo "Upgrading kubectl to $K8S_VERSION ..."

# 🔹 STEP 4: Download kubectl
cd /tmp || exit
curl -LO https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl

# 🔹 STEP 5: Install kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

# 🔹 STEP 6: Clear shell cache
hash -r

# 🔹 STEP 7: Verify kubectl version
echo "New kubectl version:"
kubectl version --client
echo "kubectl upgrade to $K8S_VERSION completed successfully!"