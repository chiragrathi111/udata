# If you want details any folder enter below commands:

* JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

* curl https://ipinfo.io/ip  (git the ip)

* du -h --max-depth=1    (This commands check which folder taking actual space)

* ps -ef | grep idempiere | grep java  (check heap size)

* ps -ef | grep java

* adduser
* passwd <user_name>

* su - <user_name>   (switch user)

Kernel log :-

* sudo dmesg -T

System log :- 

* journalctl -xe

* visudo  (This commands generally using root and user access priviledge)

# update ec2 if password need or not need

* sudo /etc/ssh/sshd_config.d/60-cloudimg-settings.conf

* sudo /etc/ssh/sshd_config  (uncomment password update) (PasswordAuthentication yes)

* sudo systemctl restart ssh  (then update)

* sudo passwd ubuntu (create password)

# After updated the password both way use like with pem no need password without pem need password

* ssh <ip>  or 
* ssh ubuntu@<ip>

* curl http://ipinfo.io/ip   (get public ip)

# added any ec2 server ssh access thhen next time no need pem file
* ssh-add ~/.ssh/vpc2.pem
* ssh ubuntu@100.48.212.149

# Idempiere plugin checked :-
* cd /opt/idempiere-server/configuration/org.eclipse.osgi
* ls 
check the specific version of our plugin and will copy in our local 
* cp path /home/ubuntu/ 
 

* sudo nano .bashrc
enter your alias (this file added your shortcut values)
alias 'k=kubectl'
alias 'de=describe'
alias kgp='kubectl get pods'
* source .bashrc 
* k
# If your running terminal changes not reflected then again run this below cammand your existing terminal
* source ~/.bashrc

# Change terminal name:
* sudo hostnamectl set-hostname Worker1 && exec bash

# delete list of records:-

* find . -type f \( -name "*.tar" -o -name "*.tar.gz" \) -mtime +7 -delete	

# Finding the current day changes list of file

* find . -mtime 0 (if want check current day file any changes and you want provide specific path)
* find ~/Documents/Rathi/Student-New/ -mtime 0

# Finding any specific file use below commands

* sudo find / -name "*.tf"  # this is very bad searching because this search root directory, so if we need their according specific path provided
* find ~/Documents/Rathi/udata/Terraform/ -name "*.tf"

* locate alb.tf (sudo apt install plocate -y) # If not install then first install this 

# check CPU and Memeory 
* top
* htop (sudo apt install htop -y) # this is good for looking wise and understanding wise

# kill any ps

* ps -ef
* sudo lsof -i :portno
* sudo kill -9 <p-id>
* pkill <process_name>


# Memory and CPU details 

* free -h
* lscpu
* df -h
* du -h
* nproc (no. of cpu)
* cat /proc/loadavg (check the load)

# Disk Management

* lsblk
* blkid
* df -Th (check the file system)

# Networking

* ip addr 
* ip route
* telnet localhost port (check the port access)
* nc -zv localhost port (check the port access)
* ss -tulnp (live network connection)

# Logs 

* journalctl (General logs)
* journalctl -b (Boot logs)
* journalctl -u nginx (nginx logs)
* journalctl -fu postgresql (postgresql logs)

# Watch (If we want get data every 2 second so using below commands)

* watch ss -tulnp
* watch free -h
* watch df -h

# View environment variable

* printenv

* echo $SHELL (check current shell)

# Last shut down

* last -x

# Last Reboot 

* last reboot

# Administrator commands :-

| Command          | Use When                                               |
| ---------------- | ------------------------------------------------------ |
| `journalctl -xe` | A service failed, system errors, startup issues        |
| `dmesg -T`       | Hardware, kernel, OOM, USB, disk, driver issues        |
| `vmstat 1`       | Check CPU, memory, swap, and I/O together in real time |
| `iostat -xz 1`   | Database or disk-intensive applications are slow       |
| `sar -u 1`       | Monitor CPU usage over time                            |
| `sar -r 1`       | Monitor memory usage over time                         |
| `sar -n DEV 1`   | Monitor network traffic on each interface              |


Memorable flow :-

Server Slow
     │
     ├── CPU?
     │      → top
     │      → vmstat 1
     │
     ├── Memory?
     │      → free -h
     │      → sar -r 1
     │
     ├── Disk?
     │      → df -h
     │      → iostat -xz 1
     │
     ├── Network?
     │      → ss -tulnp
     │      → sar -n DEV 1
     │
     └── Logs?
            → journalctl -xe
            → dmesg -T


💾 Disk

df -h
du -sh
lsblk
mount

🧠 Memory

free -h
vmstat 1
sar -r 1

⚡ CPU

top
htop
vmstat 1
sar -u 1

🌐 Network

ip addr
ping
ss -tulnp
curl
nc
sar -n DEV 1

📄 Logs

journalctl
dmesg
tail -f
grep

⚙️ Services

systemctl status
systemctl restart
systemctl start
systemctl stop