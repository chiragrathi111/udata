# I Added all commands what is createing and what is the use and benefit:-

1. Create a public and private key pair using openssl command:
   * openssl genrsa -out myuser.key 2048

2. Create a certificate signing request (CSR) using the private key:
   * openssl req -new -key myuser.key -out myuser.csr -subj "/CN=myuser"

3. Create a CSR manifest file (csr.yaml) with the following content:
```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: myuser
spec:
  request: <base64-encoded CSR content>
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
``` 
# how can get the base64-encoded CSR content:
* cat myuser.csr | base64 | tr -d '\n'

4. Apply the CSR manifest to create the CSR resource in Kubernetes:
   * kubectl apply -f csr.yaml

   * kubectl get csr myuser
   output:
NAME     AGE   SIGNERNAME                             REQUESTOR   CONDITIONS
myuser   10s   kubernetes.io/kube-apiserver-client   system:serviceaccount:kube-system:default   Pending

5. Approve the CSR to allow Kubernetes to sign the certificate:
   * kubectl certificate approve myuser

6. Check the status of the CSR to see if it has been approved and the certificate has been issued:
   * kubectl get csr myuser

   output:
NAME     AGE   SIGNERNAME                             REQUESTOR   CONDITIONS
myuser   1m    kubernetes.io/kube-apiserver-client   system:serviceaccount:kube-system:default   Approved,Issued

7. Set user Configuration:
   * kubectl config set-credentials myuser --client-certificate=myuser.crt --client-key=myuser.key
   output:
User "myuser" set.

   # If i do not have the certificate in crt format, i can use below command to create crt file from base64 encoded certificate:
   * kubectl get csr myuser -o jsonpath='{.status.certificate}' | base64 -d > myuser.crt

8. Set-context for the user:
   * kubectl config set-context myuser-context --cluster=my-cluster --user=myuser
   example:
   * kubectl config set-context myuser --cluster=dev-cluster-worker2 --user=myuser
   output:
Context "myuser" created. 

9. get Context:
   * kubectl config get-contexts
   output:
CURRENT   NAME               CLUSTER               AUTHINFO        NAMESPACE
*         kind-dev-cluster   kind-dev-cluster      kind-dev-cluster   
          myuser             dev-cluster-worker2   myuser

10. Use the context to access the cluster with the new user:
   * kubectl config use-context myuser
   output:
Switched to context "myuser".

11. Added role  for the user:
   * I created a yaml file and their according define user which resource access like below:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```
# Means this role will allow the user to get, watch and list pods in the default namespace,and only for Pod not 
for any other resource.

    * kubectl apply -f role.yml
    * kubectl get role
    * kubectl describe role pod-reader

12. Create RoleBinding:
   * I craeted a rolebinding to bind the role to the user, which will allow the user to access the resources defined 
   in the role:
   ```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: default
subjects:
- kind: User
  name: myuser
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```
# Means this RoleBinding will bind the "pod-reader" Role to the user "myuser" in the default namespace, 
allowing them to access the pods as defined in the Role.

   * kubectl apply -f binding.yml
   * kubectl get rolebinding
   * kubectl describe rolebinding pod-reader-binding

13 After Binding User can access the pods in default namespace:
   * k auth can-i get pod --as myuser
   output:
yes

    * k auth whoami --as myuser
    output:
ATTRIBUTE   VALUE
Username    myuser
Groups      [system:authenticated]

14 if we have not a ca.crt and ca.key file, we can login tp master node and get that file and copy paste
in our local machine.
* docker ps
* docker exec -it <master-node-container-name> bash
* cd /etc/kubernetes/pki
* cat ca.crt
copy that content and paste our local file
* cat ca.key
copy that content and paste our local file

15 Show Pod:-
* kubectl get pods




