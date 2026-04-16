✅ Step 1: Secure SSH

sudo nano /etc/ssh/sshd_config

Set:
PasswordAuthentication no
PermitRootLogin no

restart:
sudo systemctl restart sshd

✅ Step 2: Install Fail2Ban

sudo apt install fail2ban

✅ Step 3: Remove DB Exposure

Postgres config:

listen_addresses = 'localhost'  dont use *

sudo nano /etc/postgresql/*/main/pg_hba.conf

local all all md5

DB accessible only from same server ✅

==========================================================
🛡️ PART 1: Install & Configure Fail2Ban on Ubuntu (EC2)

sudo apt update
sudo apt install fail2ban -y
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

✅ Step 2: Create Config (VERY IMPORTANT)
Default config should NOT be edited. Create new:

sudo nano /etc/fail2ban/jail.local

[DEFAULT]
bantime = 600        # 10 minutes
findtime = 600       # check window
maxretry = 5         # attempts allowed

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log

after save

sudo systemctl restart fail2ban

sudo fail2ban-client status

sudo fail2ban-client status sshd

Someone tries 5 wrong SSH passwords
→ Fail2Ban blocks their IP automatically

🧠 Real-Time Log Check

tail -f /var/log/auth.log


🔥 KEY DIFFERENCE (VERY IMPORTANT)

| Layer          | Location      | Control               |
| -------------- | ------------- | --------------------- |
| Security Group | AWS level     | Network access        |
| NACL           | Subnet level  | Network rules         |
| UFW            | Inside server | Process-level control |


----------------------------------------------------------------------

✅ 2️⃣ SAFE WAY (BEST PRACTICE) — SSH TUNNEL 🔥

Local → SSH → EC2 → DB (localhost)

Step 1: Create SSH Tunnel

ssh -i your-key.pem -L 5432:localhost:5432 ubuntu@EC2_PUBLIC_IP

🔥 3️⃣ Even Better (GUI Way in pgAdmin)

SSH Tab:

Host: EC2 Public IP
User: ubuntu
Key file: your .pem file

