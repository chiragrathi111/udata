# install Ingress-controller

* kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# check nginx controller

* kubectl get pods -n ingress-nginx

* kubectl get all -n ingress-nginx

* kubectl get svc -n inress-nginx

* kubectl get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.96.78.86    <pending>     80:30259/TCP,443:31023/TCP   58m
ingress-nginx-controller-admission   ClusterIP      10.96.25.190   <none>        443/TCP                      58m

# If want remove <pending> then Load balancer replace to NodePort

* k edit svc ingress-nginx-controller -n ingress-nginx

Modify Type :- NodePort

and again run commands:-

* kubectl get svc -n ingress-nginx
NAME                                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             NodePort    10.96.78.86    <none>        80:30259/TCP,443:31023/TCP   65m
ingress-nginx-controller-admission   ClusterIP   10.96.25.190   <none>        443/TCP                      65m

🔥 PART 4 — Installing Ingress Controller in Cloud (AWS / EKS)

* helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace

* kubectl get svc -n ingress-nginx
output:-
EXTERNAL-IP: a1b2c3.elb.amazonaws.com

* kubectl get ingress
