On EC2-A (Jenkins server):

ssh-keygen -t ed25519 -C "jenkins-ec2a"

cat ~/.ssh/id_ed25519.pub
----------------------------------

On EC2-B (target server):

ssh -i ~/Downloads/vpc2.pem ec2-user@<EC2-B-IP>

nano ~/.ssh/authorized_keys

chmod 600 ~/.ssh/authorized_keys
--------------------------
Test from EC2-A:

ssh ec2-user@<EC2-B-IP>

-----------------------------
For Ansible on EC2-A

Update /etc/ansible/hosts:

ini[cr]
<EC2-B-IP>

[cr:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/id_ed25519

--------------------------------------------------------
Summary Flow
EC2-A (Jenkins)          EC2-B (Target)
─────────────────        ──────────────────
id_ed25519 (private) →   authorized_keys
id_ed25519.pub       →   (contains EC2-A pub key)

Jenkins connects EC2-B using its OWN private key
No PEM, No password 