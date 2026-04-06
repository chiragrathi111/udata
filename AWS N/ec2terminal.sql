How to access ec2 terminal:-

1 create a new ec2 instance
2 create a new role and provide that policy (AmazonSSMManagedInstanceCore) 
3 attached the role on the ec2 instance
  EC2 → Instance → Actions → Security → Modify IAM Role
4 Verify SSM Agent
  Systems Manager → Fleet Manager → Managed Instances

  If that is not display instance list first check policy added or not then check role attached to ec2 or not
  next willl reboot the server
  after that take some time and we observe that list is shoing on ssm manager side
  that is the every thing setup is fine. 

5 Test from AWS Console (That place also show online instead offline )

6 Install some package or need verify
  * aws --version
  * session-manager-plugin

  If not install run below commans:-

  * sudo apt install awscli -y
  * aws --version

  * curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o session-manager-plugin.deb
  * sudo dpkg -i session-manager-plugin.deb
  * sudo apt-get install -f -y
  * session-manager-plugin

7 Configure CLI
  * aws configure
  Enter:-
  Access Key
  Secret Key
  Region (ap-south-1)


8 Connect from Terminal
  * aws ssm start-session --target <Instance-id>

  output:- $

  If we check whoami 
  * whoami
  output :- ssm-user (means that is a session manager their have very less access)
  If you want to move ubuntu user or root user

  * sudo su - ubuntu (for ubuntu)
  * sudo su - ec2-user (for linux)
  * sudo su (Super User like root)

  ------------------------------------------------------------------------------------------------------------------------------------------------------------
  ************************************************************************************************************************************************************
  ------------------------------------------------------------------------------------------------------------------------------------------------------------
Ec2 terminal login using iam sso :-

Step 1 — Enable IAM Identity Center

AWS Console → Search "IAM Identity Center" → Enable

Step 2 — Create users (one per developer)

IAM Identity Center → Users → Add user
→ Enter email, name for each developer
→ They receive email invite to set their own password

Step 3 — Create Permission Sets (based on role)

IAM Identity Center → Permission sets → Create

For junior devs:   attach → AmazonSSMReadOnlyAccess
For senior devs:   attach → AmazonSSMFullAccess
For DevOps:        attach → AdministratorAccess

Step 4 — Assign users to AWS account

IAM Identity Center → AWS accounts → your account
→ Assign users → select user → select their permission set

Step 5 — Attach SSM role to EC2 (already done by you)

EC2 → Instance → Actions → Security → Modify IAM Role
→ Attach role with AmazonSSMManagedInstanceCore

rebot the server

Verify SSM Agent
  Systems Manager → Fleet Manager → Managed Instances

  If that is not display instance list first check policy added or not then check role attached to ec2 or not
  next willl reboot the server
  after that take some time and we observe that list is shoing on ssm manager side
  that is the every thing setup is fine. 

Step 6 — Install AWS CLI v2

-- check
aws --version

# Install v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify
aws --version
# Must show: aws-cli/2.x.x

Step 7 — Install Session Manager Plugin

-- check
session-manager-plugin

curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o session-manager-plugin.deb
sudo dpkg -i session-manager-plugin.deb
session-manager-plugin

Step 8 — Configure SSO

Option A — SSO Login (No Access Key needed)

aws configure sso

SSO session name:  my-company-sso
SSO start URL:     https://d-xxxxxxxxxx.awsapps.com/start
SSO region:        ap-south-1
Scopes:            (just press Enter)

# Browser opens → login with Identity Center email/userName + password
# Select your AWS account → select permission set
# Profile name: dev-profile

aws sso login --profile my-profile

# Connect to EC2
aws ssm start-session --target i-0d5bdbeb86e03902e \
  --region ap-southeast-2 \
  --profile my-profile

------------------------------------------------------
Option B — Access Key (No SSO needed)

# Configure with keys
aws configure
# Enter Access Key + Secret Key + region

# Connect to EC2
aws ssm start-session --target i-0d5bdbeb86e03902e --region ap-southeast-2

Step 9 — Connect to any EC2

aws ssm start-session --target i-0xxxxxxxxxxxxxxxxx --region ap-south-1

if got any error or not terminal login

Error:-
An error occurred (TargetNotConnected) when calling the StartSession operation: i-0d5bdbeb86e03902e is not connected.

then first check what is aws configure region

aws configure list


and modify region our requirement according. 

