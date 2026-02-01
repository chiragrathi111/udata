* kubectl get namespaces  (or kubectl get ns)

* kubectl describe namespace <namespace-name>

* kubectl delete namespace <namespace-name>

* kubectl create namespace <namespace-name>

* kubectl edit namespace <namespace-name>

* kubectl label namespace <namespace-name> <label-key>=<label-value>

* kubectl annotate namespace <namespace-name> <annotation-key>=<annotation-value>

* kubectl get namespace <namespace-name> -o yaml/json

* kubectl apply -f <namespace-definition-file>.yaml

* kubectl get all --namespace=<namespace-name>

* kubectl config set-context --current --namespace=<namespace-name>

* kubectl get pods -n <namespace-name>

* kubectl config set-context <context-name> --namespace=<namespace-name>