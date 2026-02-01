# Commands:- 

* kubectl get nodes

* kubectl get pods

* kubectl get pods -o wide (Details)

* kubectl get nodes -o wide (Details)

* kubectl describe pod environments

* kubectl log pod environments

* kubectl describe pod environments

* kubectl exec -it environments -- env

* kubectl exec -it environments -- printenv MYNAME
o/p:- 
CHIRAG RATHI
(value)

* kubectl get pod environments -o yaml

* kubectl exec -it testpod2 -c <container-name> -- printenv MYNAME

* kubectl exec -it testpod4 -- bash
if login inside pod then you check and run the below commands

curl localhost:80

apt update
apt install net-tools -y
netstat -tulpn  (install and check)

* kubectl port-forward pod/testpod4 8080:80
(if not login to pod so directly run that command)

1️⃣ Get pods by label (most common)

* kubectl get pods -l env=development

2️⃣ Get pods with multiple labels

* kubectl get pods -l env=development,class=pods

3️⃣ Show labels with pods

* kubectl get pods --show-labels

o/p :- 


5️⃣ Get pods NOT matching a label

* kubectl get pods -l env!=production

6️⃣ Get pods using label existence

* kubectl get pods -l env

# Added label any running pod not need to added yaml file 
* kubectl label pod testpod env=prod

* kubectl get pods testpod --show-labels

* kubectl get rc  (Show Replication Controller)
o/p sow Replica 
NAME        DESIRED   CURRENT   READY   AGE
myreplica   2         2         2       80s

* kubectl apply -f pod8.yml --dry-run=client
replicationcontroller/myreplica configured (dry run)
(First dont apply run dry run if not getting any error thhen run that commands)

* kubectl scale rc myreplica --replicas=4  (Increse Replica Controller)

* kubectl scale rc myreplica --replicas=1   (Decrese size If we enter that qty updated)

* kubectl delete rc myreplica  (Deleted replicas)

* kubectl get rs (Show Replica set)

* kubectl describe rs myrs

* kubectl scale rs myrs --replicas=4 (Set Replica Set)

* kubectl delete rs myrs

* kubectl exec -it <pod_name> -c <container_name> -- /bin/bash (login specific pod and specific container)

* kubectl get pv  (get Prevent Volume list)

* kubectl get pvc (get Prevent Volume claim list)

* kubectl get pods

* kubectl exec -it liveness-pod -- /bin/bash  (login in pod)
* env   (run env command to see environment variables)

* kubectl create configmap myapp --from-file=sample.conf  (Added config file)

* echo "root" >username.txt; echo "password" > password.txt  (Testin purpose run file,file size max 1 mb)

* kubectl create secret generic mysecret --from-file=password.txt --from-file=username.txt  (secret_name = mysecret)

* kubectl get secret  (get secret list)


