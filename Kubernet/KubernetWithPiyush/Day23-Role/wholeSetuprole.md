1️⃣ Generate private key

* openssl genrsa -out myuser.key 2048

✅ Correct

What it creates

myuser.key → private key (secret)

Used to prove identity

🧠 Think: Password file (never share)

2️⃣ Create CSR

* openssl req -new -key myuser.key -out myuser.csr -subj "/CN=myuser"

✅ Correct

What it does

Requests Kubernetes: “Please create a cert for user myuser”

🧠 CN = username in Kubernetes

3️⃣ CSR YAML

apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: myuser
spec:
  request: <base64-encoded CSR>
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth

✅ Correct

Encode CSR
* cat myuser.csr | base64 | tr -d '\n'

✅ Correct

⚠️ Important

Must be single line

No spaces or line breaks

4️⃣ Apply CSR

* kubectl apply -f csr.yaml
* kubectl get csr myuser

✅ Correct

Pending = waiting for admin approval

5️⃣ Approve CSR

* kubectl certificate approve myuser

✅ Correct

🧠 Kubernetes CA signs the certificate internally

6️⃣ Certificate issued

* kubectl get csr myuser

Output:-
Approved,Issued

✅ Correct

⚠️ Important

Certificate is stored inside the CSR object, not as a file

7️⃣ Extract certificate

* kubectl get csr myuser -o jsonpath='{.status.certificate}' | base64 -d > myuser.crt

✅ Correct and REQUIRED

🧠 Now you have:

myuser.key → private key

myuser.crt → signed certificate

8️⃣ Add user to kubeconfig

* kubectl config set-credentials myuser \
  --client-certificate=myuser.crt \
  --client-key=myuser.key

✅ Correct

🧠 “kubectl, this is how to login as myuser”

9️⃣ Create context

* kubectl config set-context myuser \
  --cluster=dev-cluster-worker2 \
  --user=myuser

⚠️ Small fix

Cluster name must match:

kubectl config get-clusters

If cluster name is kind-dev-cluster, use that.

Otherwise ❌ auth will fail.

🔟 Switch context

* kubectl config use-context myuser

✅ Correct

🧠 You are now logged in as myuser

1️⃣1️⃣ Create Role (Pod read-only)

rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]

✅ Perfect

🚫 Cannot:

create pods

delete pods

access services, secrets, nodes

1️⃣2️⃣ RoleBinding

subjects:
- kind: User
  name: myuser

✅ Correct

🧠 This is the link:

User → Role → Permissions

1️⃣3️⃣ Test access

* kubectl auth can-i get pod --as myuser
output:
yes

* kubectl auth whoami --as myuser
output:
ATTRIBUTE   VALUE
Username    myuser
Groups      [system:authenticated]

⚠️ BIG SECURITY WARNING (STEP 14)

❌ DO NOT COPY ca.key EVER

This part is WRONG & DANGEROUS:

cat ca.key
copy that content

🚨 If someone gets ca.key → they become cluster admin

Correct rule:

✅ ca.crt → OK to copy

❌ ca.key → NEVER COPY

🧠 Kubernetes intentionally hides CA key
That’s why CSR API exists.

1️⃣5️⃣ Pod access

* kubectl get pods

✅ Works (default namespace only)
