# Rollout Commands:-

* kubectl rollout status deployment <deployment_name>

* kubectl rollout history deployment <deployment_name>

* kubectl rollout undo deployment mydeployment (just one old version)

* kubectl rollout undo deployment <deployment_name> --to-revision=<revision_number>

# Deployment Commands:-

* kubectl get deploy 

* kubectl get deploy mydeployment 

* kubectl describe deploy mydeployment

* kubectl create deploy mydeployment --image=nginx

* kubectl set image deploy mydeployment nginx=nginx:1.16.1

* kubectl scale deploy mydeployment --replicas=5

* kubectl delete deploy mydeployment

* kubectl exec -it <pod_name> -- /bin/bash

# Example:-
