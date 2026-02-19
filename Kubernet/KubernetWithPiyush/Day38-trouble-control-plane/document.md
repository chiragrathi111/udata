# If any case below commands is not wortking
* kubectl get node

output:- gotting error

# Solutions:-
1. Check your api-server is up and running or not
* crictl ps (if not showing)
* crictl ps -a
* crictl ps |grep api
* crictl ps -a |grep api
(This commands you find out our api server still running or not if not running then check logs)

If your container is up and running and just down then you also try to check logs
* cd /var/log/containers/
* ls -lrt

* crictl logs <id/name>
Then you saw and try resolving what is the actual issue.

2. If our case not a api issue then check config file 
* cd $HOME/.kube
* cat config
If you not found any thing then you try to check admin.conf file
* cd /etc/kubernets/
* ls -lrt
will showing admin.conf file so run below commands
* kubectl get nodes --kubeconfig admin.conf
If any permission issue gave admin.conf access
* sudo chmod 755 admin.conf
* kubectl get nodes --kubeconfig admin.conf
If you got nodes means our config file and admin.conf file location will change

Try to run below commands
* export KUBECONFI=$HOME/.kube/config
* kubectl get node (I thing it's working fine)

3. If any case we run the pod using yaml file or directly run pod using image but this pod is not running
This case Fisrt we check
* kubectl get pod
* kubectl describe pod <name>
* kubectl logs pod <name>

I already face docker issue, some time my image not pull so that issue i know how can resolve

If any case pod not assign node that is the reason our base pod not proper working
* kubectl get pod -n kube-system
(Check all pods is running or not)
If any specific pod facing issue so describe that pod and check what is the actual issue

4. Some time i use Depoly/Replica Set/Replica Controller and i set replicas like 2 
like we run 
* kubectl get pods  (showing 2)
* kubectl get deploy (showing 2)
I delete any pod manually, if every thing is working fine then new pod automatic created.
but some time newpod not created means check base pods like (kube-controller-manager)
If this pod is not running properly then time pod not auto created
check the logs and describe and find out what isthe actual issue.
Note:- If not proper scale that directly managed by kube-controller-manager

5. Some time you also check that below commads:-
* kubectl cluster-info
* kubectl cluster-info dump
