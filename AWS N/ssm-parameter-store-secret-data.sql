Starting we are use hardcode password or using env varibale but the best approach using ssm-parameter/aws secret manager to store the password and get the password
and use it. 

SSM Parameter :-

🚀 STEP 1 — Create EC2 Instance

Create:

Ubuntu EC2
t2.micro enough
allow SSH

🚀 STEP 2 — Create IAM Role

AWS Console
→ IAM
→ Roles
→ Create Role

Choose:

AWS Service → EC2

Attach policy:

AmazonSSMReadOnlyAccess

Role name:

EC2-SSM-Role

🧠 What this role does?

This role tells AWS:

"This EC2 is allowed to read SSM parameters"

🚀 STEP 3 — Attach Role to EC2

EC2
→ Actions
→ Security
→ Modify IAM Role

Attach:

EC2-SSM-Role
🔥 IMPORTANT UNDERSTANDING

Now EC2 becomes trusted machine.

Like:

AWS says:
"Okay, this server can access secrets"

WITHOUT:

AWS access key
secret key
login password

This is huge concept in AWS.

🚀 STEP 4 — Store Secret in SSM

AWS Console
→ Systems Manager
→ Parameter Store
→ Create parameter

Create:
Field	Value
Name	/prod/db/password
Type	SecureString
Value	mypassword123

🧠 Now Where is password?

NOT in EC2.

Stored securely in AWS:

SSM Parameter Store

encrypted.

🚀 STEP 5 — SSH into EC2

ssh -i mykey.pem ubuntu@<public-ip>

🚀 STEP 6 — Install Node.js

Ubuntu :- 
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install nodejs -y

Linux:-

curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs

node -v
npm -v

🔥 After Node install

mkdir secret-test
cd secret-test

npm init -y
npm install aws-sdk

nano app.js

copy below code 

const AWS = require('aws-sdk');

const ssm = new AWS.SSM({
    region: 'ap-south-1'
});

async function getSecret() {
    try {
        const data = await ssm.getParameter({
            Name: '/prod/db/password',
            WithDecryption: true
        }).promise();

        console.log('DB Password:', data.Parameter.Value);

    } catch (err) {
        console.error(err);
    }
}

getSecret();


🚀 Run

node app.js

=========================================================================================
Secret Manager :-

🚀 STEP 1 — Create Secret

AWS Console

→ Secrets Manager
→ Store a new secret

Choose:
Other type of secret
Add values

Example:

Key	Value
username	postgres
password	mypassword123

Secret name
prod/db/credentials

Store

🧠 Important Understanding

Now AWS stores:

{
  "username": "postgres",
  "password": "mypassword123"
}

securely + encrypted.

🚀 STEP 2 — Give EC2 Permission

Earlier for SSM you used:

AmazonSSMReadOnlyAccess

Now for Secrets Manager:

Go:

IAM
→ Roles
→ EC2-SSM-Role

Add policy:

SecretsManagerReadWrite

(For testing purpose okay)

🧠 What this means?

AWS now trusts:

"This EC2 can read secrets"

🚀 STEP 3 — Install AWS SDK

Inside EC2:

mkdir secrets-data
cd secrets-data

npm init -y
npm install aws-sdk

🚀 STEP 4 — Create App
nano app.js

const AWS = require('aws-sdk');

const secretsManager = new AWS.SecretsManager({
    region: 'ap-south-1'
});

async function getSecret() {
    try {

        const data = await secretsManager.getSecretValue({
            SecretId: 'prod/db/credentials'
        }).promise();

        const secret = JSON.parse(data.SecretString);

        console.log('Username:', secret.username);
        console.log('Password:', secret.password);

    } catch (err) {
        console.error(err);
    }
}

getSecret();

🚀 STEP 5 — Run App
node app.js


🎉 Expected Output
Username: postgres
Password: mypassword123
=====================================================================================================