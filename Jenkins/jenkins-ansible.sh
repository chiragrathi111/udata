Do on Web Configure inside job:-

Invoke Ansible Playbook

Playbook path

/etc/ansible/playbooks/test1.yml

Inventory

File or host list

/etc/ansible/hosts

save it

if you build the job you gotting error so below steps follow then solve that error 
------------------------------------
Do on Terminal :-

Step 1 — Properly switch to jenkins user

sudo su - jenkins -s /bin/bash

# Verify you are jenkins
whoami
# Should show: jenkins

# Check jenkins home
echo $HOME
# Should show: /var/lib/jenkins

Step 2 — Setup SSH for jenkins user

# As jenkins user
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate key
ssh-keygen -t ed25519 -C "jenkins"
# Enter → /var/lib/jenkins/.ssh/id_ed25519
# Press Enter for no passphrase

# View public key
cat ~/.ssh/id_ed25519.pub
# Copy this output

Step 3 — Add keyscan

# Still as jenkins user
ssh-keyscan -H 98.130.124.206 >> ~/.ssh/known_hosts    # If any time your ip change replace the ip and run this commands
chmod 600 ~/.ssh/known_hosts

Step 4 — Add jenkins public key to target EC2-B
Open new terminal:

ssh -i ~/Downloads/crat.pem ec2-user@16.112.58.51

nano ~/.ssh/authorized_keys
# Paste jenkins public key from Step 2
# Save and exit

Step 5 — Test from jenkins user

# Back on EC2-A, as jenkins user
ssh ec2-user@98.130.124.206
# Must work without password ✅

Step 6 — Update ansible hosts

exit  # exit jenkins user
sudo nano /etc/ansible/hosts

[cr]
16.112.58.51

[cr:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/id_ed25519

-------------------------------------------------------------------------------
after performing all 6 steps every thing is working fine.

If we are doing Jenkins user every thing is working fine,because system want use jenkins user instead of ubuntu/ec2-user

====================================================================
If we want to access private git 

1 create a ssh key
ssh-keygen

and copy to public key
and paste it to git hub 

Setting -> SSH key -> Add new -> 
 fill the tittle and key (already to copy public key) and save it

After saving the public key in git hub then will create a credential on the jenkins server

Manage Jenkins -> Credentails -> System -> Global -> Add Credential -> Select SSH username and private key

Id - fill any name
DEscription - any
Username - ubuntu/ec2-server
Checked directly private key

go to terminal and copy the private key starting you created like using ssh-keygen

and then sure remove any white space or line in this copy paste place and after that press ok

Note :- If we are using private git, so config section using ssh url instaed of https url
and after that select credentail other wise you got the error.


---------------------------------------
Trigger :-

1 Build periodically - enter time their accoding trigger

* * * * *  (like every min)

2 Poll SCM :- If our Git is public so and we want if git have any changes automatic trigger so using that option
their have also time trigger and we enter
* * * * *  so every min check if git have any changes then trigger other wise skip this is also good 

This is not recommanded because this is incraese the load on the server

3 GitHub hook trigger for GITScm polling :-

If we have private Git so we are using this option, so this is automatic trigger but some setup 

Git Hub Side 

Go to Repository -> Repository Setting -> Webhook -> Add Webhook ->

Payload URL - jenkinsurl/github-webhook/
Example - ec2 ip/public dns:8080/github-webhook/

Content Type - Application/json

Which events would you like to trigger this webhook?
select ratio button 
Let me select individual events. (Select)

select check box

Pushes
Pull requests

after that hit Add webhook

After complete Git hub side then again go to jenkins page and go to job confic and select trigger side 4 option and hit apply and save

3 rd option is the best option