🔑 PART 1: Create private key (identity of user)

* openssl genrsa -out chirag.key 2048
📌 This is password-like secret key
📌 Keep it safe

🧾 PART 2: Create CSR (request to Kubernetes)

* openssl req -new -key chirag.key -out chirag.csr -subj "/CN=chirag"
📌 CN = username in Kubernetes
📌 This file is NOT a certificate

🔄 PART 3: Convert CSR to base64 (Kubernetes needs this)

* cat chirag.csr | base64 | tr -d '\n'
📌 Copy the entire output

📄 PART 4: Create CSR YAML (VERY IMPORTANT)

* nano chirag-csr.yaml
Paste this (replace <BASE64_CSR>):

apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: chirag
spec:
  request: <BASE64_CSR>
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 31536000   # 1 year
  usages:
  - client auth

📤 PART 5: Submit CSR to Kubernetes

* kubectl apply -f chirag-csr.yaml
* kubectl get csr

✅ PART 6: Approve CSR (ADMIN ONLY)

* kubectl certificate approve chirag
* kubectl get csr chirag

📜 PART 7: Extract signed certificate (THIS WAS YOUR BIG CONFUSION)

👉 Kubernetes does NOT create .crt file automatically

* kubectl get csr chirag -o jsonpath='{.status.certificate}' | base64 -d > chirag.crt

Verify certificate:
* openssl x509 -in chirag.crt -noout -subject -dates

✅ If this works → cert is correct

⚙️ PART 8: Add user credentials to kubeconfig

* kubectl config set-credentials chirag \
  --client-certificate=chirag.crt \
  --client-key=chirag.key

🔗 PART 9: Create context for user

* kubectl config set-context chirag \
  --cluster=kind-dev-cluster \
  --user=chirag

🔐 PART 10: RBAC – Allow POD read access

Create Role
* nano pod-reader.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]

* kubectl apply -f pod-reader.yaml

Bind Role to user
* nano pod-reader-binding.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: default
subjects:
- kind: User
  name: chirag
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io

* kubectl apply -f pod-reader-binding.yaml

🌍 PART 11: RBAC – Allow NODE read access (cluster-wide)

Create ClusterRole
* nano node-reader.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]

* kubectl apply -f node-reader.yaml

Bind ClusterRole
* nano node-reader-binding.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-reader-binding
subjects:
- kind: User
  name: chirag
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: node-reader
  apiGroup: rbac.authorization.k8s.io

* kubectl apply -f node-reader-binding.yaml

🔄 PART 12: Switch to user chirag

* kubectl config use-context chirag
* kubectl config get-contexts

🧪 PART 13: Test access (FINAL CONFIRMATION)

* kubectl get pods
* kubectl get nodes

❌ Try forbidden action:
* kubectl delete pod test

output:- Forbidden

