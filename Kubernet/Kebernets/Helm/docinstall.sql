* curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

* helm repo add bitnami https://charts.bitnami.com/bitnami

* helm repo update

* helm repo list

* helm search repo tomcat

* helm install testchart bitnami/tomcat

* helm install testchart bitnami/tomcat --set service.type=NodePort

* kubectl get all
* kubectl get svc

* helm list

* helm version

* which helm

* helm repo add stable https://charts.helm.sh/stable

* helm install <chart-name> stable/tomcat --set service.type=NodePort

* helm repo add bitnami https://charts.bitnami.com/bitnami
* helm repo update

* helm repo list

* helm install testchart2 bitnami/tomcat --set service.type=NodePort
* helm list

* helm show all

* kubectl get all
* kubectl get svc

* minikube service testchart2 --url
* helm uninstall testchart2 testchart2
* helm list

* helm search repo bitnami
* helm search hub nginx

* kubectl describe svc texttom-tomcat

