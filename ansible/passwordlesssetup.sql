✅ METHOD 1 (RECOMMENDED – Best for Ansible)
Step 1️⃣ Create your own SSH key (local machine)
ssh-keygen -t ed25519


Press Enter for all questions.

This creates:

~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub

Step 2️⃣ Copy public key using PEM (manual but clean)

Login using PEM:

ssh -i ~/Downloads/vpc2.pem ubuntu@44.223.3.20


On the server:

mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys

Note:- Do not remove exiting line below added your line,If you remove then othher person cant login only you login in your laptop. 


Now on local machine, copy:

cat ~/.ssh/id_ed25519.pub


Paste it into authorized_keys, save, exit.

Fix permissions:

chmod 600 ~/.ssh/authorized_keys
exit

Step 3️⃣ Test passwordless login
ssh ubuntu@44.223.3.20

----------------------------
TG - Idea:-
* ssh-keygen
* ls -la
* cd .ssh
* ls
* ssh-copy-id ubuntu@<ip>
if do above commands so no need to loin node and paste this is a good way 
after run last command ask one time password then next time never ask again

* cd
* ssh <ip> OR 
* ssh ubuntu@<ip>

If this copy-id not working for pem file case so then time you manually copy and paste pub key, first pararaph details alraedy provided

---------------------------------------------------
sudo nano /etc/ansible/hosts

[cr]
3.85.204.185

[cr:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/Downloads/vpc2.pem

Starting i use ubuntu@<ip>, but best way name:vars :- we added more ting so easily gotting connection

after added this thing ansible commands ruuing properly


==============================================
# update ec2 if password need or not need

* sudo /etc/ssh/sshd_config.d/60-cloudimg-settings.conf

* sudo /etc/ssh/sshd_config  (uncomment password update) (PasswordAuthentication yes)

* sudo systemctl restart ssh  (then update)

* sudo passwd ubuntu (create password)

# After updated the password both way use like with pem no need password without pem need password

* ssh <ip>  or 
* ssh ubuntu@<ip>

=================================================================
TG - Idea:-
* ssh-keygen
* ls -la
* cd .ssh
* ls
* ssh-copy-id ubuntu@<ip>
if do above commands so no need to loin node and paste this is a good way 
