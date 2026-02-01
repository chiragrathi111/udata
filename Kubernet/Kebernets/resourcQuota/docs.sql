# Install the metrics server components

* wget -O metrics-server.yaml https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

* kubectl apply -f metrics-server.yaml

# Verify the metrics server is running

* kubectl get deployment metrics-server -n kube-system

OR

* kubectl get pods -n kube-system | grep metrics

# Wait for a few minutes and then check the metrics

* kubectl top nodes

* kubectl top pods

# If you see metrics for nodes and pods, the metrics server is working correctly.

# Clean up the metrics server components (optional)

* kubectl delete -f metrics-server.yaml
* rm metrics-server.yaml

# Alternative: Using Minikube to enable metrics server
* minikube addons enable metrics-server
* minikube addons disable metrics-server




* kubectl get namespaces

o/p showing all namespaces

* kubectl get pods -n kube-system

o/p showing all pods in kube-system namespace (like metrics-server, coredns etc)

* kubectl logs -f <metrics-server-pod-name> -n kube-system

# Horizontal Autoscaling based on metrics server

* kubectl autoscale deployment <deployment-name> --min=2 --max=5 --cpu-percent=50
<deployment-name> should be replaced with your actual deployment name

* kubectl get all

* watch kubectl get all