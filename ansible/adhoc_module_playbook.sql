# Ad Hoc Example:-
* ansible demo -a 'ls'
* ansible -a "ls" all
(demo called group, a called argument, ls linux command)
(If you have /etc/ansible/hosts then you easily run above command)
(otherwise run * ansible -i inventory.ini demo -a 'ls')

* ansible demo -a "sudo yum install httpd -y"
      OR 
* ansible demo -ba "yum install httpd -y"   
(above both command working equally, ansible side root denote become and short form b,so this b write before a so we do not need sudo )   


#Module Examples:-
* ansible demo -b -m yum -a "pkg=httpd state=present"

* ansible demo -b -m service -a "name=httpd state=started"

* ansible demo -b -m copy -a "src=file1 dest=/home/ubuntu/"

* ansible demo -b -m user -a "name=crat"  (user created if you want delete any user then also use state= absent)

* ansible demo -m setup (node showing current configguration or any thing)

* ansible demo -m setup -a "*ipv4*"

(m represent module, yum and service module name)
(linux install = present, remove = absent, update = latest)

#playbook

* ansible-playbook file.yml
