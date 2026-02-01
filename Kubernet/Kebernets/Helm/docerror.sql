✅ Option 1: Clean unused images (BEST FIRST STEP)

* minikube ssh

Inside minikube:

* docker system df  (list disk usage)

* docker system prune -af (clean unused images, containers, volumes, networks)

* docker system df  (verify cleaned up)

* exit  (exit minikube ssh)


Check namespace used by Helm release
* helm list -A

See namespace of all resources (pods, svc, deploy)
* kubectl get all -A