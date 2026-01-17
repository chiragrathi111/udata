
Working:-

* sudo apt update

* sudo apt install -y ansible

* ansible --version

-----------------------------------------------------
* vi /etc/ansible/hosts  (This file need to create a group and define node private ip link to group)
(In the begining ansible folder or hosts file not available so do not panic create manually and <user_name>@<IP> enter you also define group)

if you have multiple ggroup that is also posible
[app]
ubuntu@44.223.3.20

[db]
ubuntu@54.160.29.33

if you use this default file so we easily check all hosts
* ansible all --list-hosts
  hosts (2):
    ubuntu@44.223.3.20
    ubuntu@54.160.29.33

* ansible db --list-hosts
  hosts (1):
    ubuntu@54.160.29.33

* ansible db[0] --list-hosts    (any specific node :- 0 means 1st node ,-1 means last node)
* ansible db[0:2] --list-hosts

* vi /etc/ansible/ansible.cfg (This file using uncocmment config line like inventory and sudo_user )

* root

* visudo
(user ave wole access without password
after run any command preffix use sudo)

* su - <user>

# If we want to connect node server first changes ssh file

* sudo nano /etc/ssh/sshd_config
(
1. uncocmment PermitRootLogin yes
2. uncocmment PasswordAuthentication yes
3. comment PasswordAuthentication no)

* sudo systemctl restart sshd

this same task do all main server and node server 
------------------------------------------------------
* ssh <node11_private_ip>   (permission deny)

* we want modify sshd-config file :-

* vi /etc/ssh/sshd-config
=======================================================================================
* ansible -i inventory.ini -m ping all
ubuntu@54.160.29.33 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: ubuntu@54.160.29.33: Permission denied (publickey,password).",
    "unreachable": true
}
ubuntu@44.223.3.20 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
First is failed because this is based on password not auto password

* * ansible -i inventory.ini -m ping ubuntu@<ip>

* ansible -i inventory.ini -m shell -a "apt install openjdk" all  (install both server ) 

above code getting error then use below code and install 

* ansible -i inventory.ini -m apt -a "name=openjdk-17-jdk state=present update_cache=yes" all --become

* ansible -i inventory.ini -m command -a "whoami" all --become
(-m = module, -a = argument)
(command/shell)
(check node root or normal user)


======================================================
sudo nano inventory.ini 

ubuntu@44.223.3.20
ubuntu@54.160.29.33

ctrl + x  

* ansible -i inventory.ini -m ping all

and run command getting all

if you have multiple ggroup that is also posible
[app]
ubuntu@44.223.3.20

[db]
ubuntu@54.160.29.33

ctrl +x

* ansible -i inventory.ini -m ping db  (show run only db group ips not all)