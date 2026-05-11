Master and Node (Server) Setup :-

Creating a Jenkins Agent Node on AWS EC2

Architecture
Master Node (Jenkins Server)  →  Agent Node (New EC2)

   18.61.252.231                    New EC2 Instance

Step 1 — Launch a New EC2 Instance (Agent)

Go to AWS Console → EC2 → Launch Instance
Configure:

Name: jenkins-agent
AMI: Amazon Linux 2 (same as your master)
Instance type: t2.micro (free tier)
Key pair: Use the same key pair as your master
Security Group: Allow inbound port 22 (SSH) from your masters IP


Step 2 — Install Java on Agent EC2
SSH into your new agent EC2 and run:
bashsudo yum update -y
sudo yum install java-17-amazon-corretto -y

# Verify
java -version

Step 3 — Create Jenkins User on Agent

sudo useradd -m -s /bin/bash jenkins

# Set password (optional)
sudo passwd jenkins

# Create workspace directory
sudo mkdir -p /home/jenkins/workspace
sudo chown -R jenkins:jenkins /home/jenkins

Step 4 — Setup SSH Key on Master
SSH into your Master Jenkins EC2 and run:

sudo su - jenkins

# Generate SSH key (press Enter for all prompts)
ssh-keygen -t rsa -b 4096

# View the public key (copy this)
cat ~/.ssh/id_rsa.pub

Step 5 — Add Public Key to Agent
SSH into your Agent EC2 and run:
bashsudo su - jenkins

mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Paste the public key from Step 4
echo "PASTE_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys

chmod 600 ~/.ssh/authorized_keys

Step 6 — Test SSH Connection from Master
On your Master EC2:
bashsudo su - jenkins

# Test connection (use agent's private IP)
ssh jenkins@<AGENT_PRIVATE_IP>

# You should login without password ✅

Jenkins Agent via JNLP (Java Web Start)
Why Companies Prefer This
SSH Method    → Master connects TO Agent  (needs SSH access)
JNLP Method   → Agent connects TO Master  (agent initiates, more secure)
No need to open SSH ports — agent just needs outbound access to Jenkins master on port 8080.

Step 1 — Configure Master to Allow JNLP
Go to Manage Jenkins → Security:

Find Agents section
Set TCP port for inbound agents → Fixed: 50000
Click Save


Step 2 — Create Node in Jenkins UI

Manage Jenkins → Nodes → New Node
Fill in:

FieldValueNode nameagent-1TypePermanent Agent

Configure:

FieldValue# of executors2Remote root directory/home/jenkins/workspaceLabelsagent-1UsageUse this node as much as possibleLaunch methodLaunch agent by connecting it to the controller

Step 3 — Open Ports on Agent EC2 Security Group
In AWS Console → EC2 → Agent instance → Security Group → Inbound Rules:
TypePortSourceCustom TCP50000Master EC2 IPCustom TCP8080Master EC2 IP

Step 4 — Prepare Agent EC2
SSH into your Agent EC2 and run:

sudo yum update -y
sudo yum install java-17-amazon-corretto -y

# Create jenkins user and workspace
sudo useradd -m -s /bin/bash jenkins
sudo mkdir -p /home/jenkins/workspace
sudo chown -R jenkins:jenkins /home/jenkins

Step 5 — Get Agent Connection Command from Jenkins

Go to Manage Jenkins → Nodes → agent-1
You will see a page like this:

Run from agent command line:

curl -sO http://18.61.252.231:8080/jnlpJars/agent.jar
java -jar agent.jar \
  -url http://18.61.252.231:8080/ \
  -secret  xxxxxxxxxxxxxxxxxxxxxxxx \
  -name "agent-1" \
  -workDir "/home/jenkins/workspace"

Copy that exact command — the secret is unique to your agent


Step 6 — Run Agent on Agent EC2
SSH into Agent EC2 and run:

sudo su - jenkins
cd /home/jenkins/workspace

# Download agent.jar from master
curl -sO http://<MASTER_PUBLIC_IP>:8080/jnlpJars/agent.jar

# Run the agent (paste command from Step 5)
java -jar agent.jar \
  -url http://<MASTER_PUBLIC_IP>:8080/ \
  -secret <YOUR_SECRET> \
  -name "agent-1" \
  -workDir "/home/jenkins/workspace"

Step 7 — Make Agent Run Permanently (Service)
So agent auto-starts on reboot:

sudo nano /etc/systemd/system/jenkins-agent.service
Paste this:
ini[Unit]
Description=Jenkins Agent
After=network.target

[Service]
User=jenkins
WorkingDirectory=/home/jenkins/workspace
ExecStart=/usr/bin/java -jar /home/jenkins/workspace/agent.jar \
  -url http://<MASTER_PUBLIC_IP>:8080/ \
  -secret <YOUR_SECRET> \
  -name "agent-1" \
  -workDir "/home/jenkins/workspace"
Restart=always

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload
sudo systemctl enable jenkins-agent
sudo systemctl start jenkins-agent

# Check status
sudo systemctl status jenkins-agent

Step 8 — Verify in Jenkins
Go to Manage Jenkins → Nodes → agent-1
You should see:
Agent is connected ✅

Summary Flow
Agent EC2                          Master EC2
──────────────────────────────────────────────
java -jar agent.jar   ──connects──▶  :50000
                        outbound      Jenkins
No SSH needed ✅
No inbound ports on agent ✅