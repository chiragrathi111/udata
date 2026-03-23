If any reason our worker node is not ready and we want to check the log then below commands follow:-

* journalctl -u kubelet
# kubelet = worker pod
# journalctl = checking the logs


First i try to run kubelet service start after that out problem not solving will check
* sudo service kublate status
* sudo service kubelet start

after that not working our node then run different trouble shooting

* cd /var/lib/kubelet/
* sudo vi config.yaml
Check file any gotting error
* ls /etc/kubernets/pki/ca.crt

after any changes our config file restart the kubelet server
* sudo service kubelet restart
