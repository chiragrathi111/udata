# Phase 5 — AWS Deployment Guide
## EC2 + Parameter Store + RDS + Docker Deploy

---

## Table of Contents
1. [Architecture Overview](#1-architecture-overview)
2. [AWS Services and Cost](#2-aws-services-and-cost)
3. [Step 1 — AWS Account Setup](#3-step-1--aws-account-setup)
4. [Step 2 — Create EC2 Instance](#4-step-2--create-ec2-instance)
5. [Step 3 — Connect via SSH](#5-step-3--connect-via-ssh)
6. [Step 4 — Install Docker on EC2](#6-step-4--install-docker-on-ec2)
7. [Step 5 — Parameter Store](#7-step-5--parameter-store)
8. [Step 6 — IAM Role](#8-step-6--iam-role)
9. [Step 7A — Deploy with Docker](#9-step-7a--deploy-with-docker-approach-a)
10. [Step 7B — Deploy with RDS](#10-step-7b--deploy-with-rds-approach-b)
11. [Step 8 — Test Live API](#11-step-8--test-live-api)
12. [Auto-Start on Reboot](#12-auto-start-on-reboot)
13. [Update App — New Version](#13-update-app--new-version)
14. [Common Errors and Fixes](#14-common-errors-and-fixes)
15. [Cost Management](#15-cost-management)
16. [Quick Checklist](#16-quick-checklist)

---

## 1. Architecture Overview

```
Internet
    ↓
User hits: http://YOUR-EC2-IP:8081/api/students
    ↓
┌─────────────────────────────────────────────┐
│              AWS EC2 Instance               │
│         (Virtual Linux Server)              │
│                                             │
│  ┌──────────────────────────────────────┐   │
│  │  Docker Container: student-app       │   │
│  │  Spring Boot on port 8081            │   │
│  └──────────────────┬───────────────────┘   │
│                     │ reads secrets from    │
│  ┌──────────────────▼───────────────────┐   │
│  │  AWS Parameter Store                 │   │
│  │  /student-app/prod/DB_URL            │   │
│  │  /student-app/prod/DB_PASSWORD (🔒)  │   │
│  └──────────────────┬───────────────────┘   │
└─────────────────────┼───────────────────────┘
                      │ connects to
┌─────────────────────▼───────────────────────┐
│              AWS RDS (optional)             │
│         PostgreSQL 15 Managed DB            │
└─────────────────────────────────────────────┘
```

### Two Deployment Approaches

```
Approach A — Docker on EC2 (RECOMMENDED for learning):
  Everything in Docker containers on EC2
  PostgreSQL inside Docker container
  Simpler — same as local dev!
  ✅ Start with this

Approach B — JAR + RDS (Production grade):
  JAR running directly on EC2 or in Docker
  PostgreSQL on AWS RDS (managed)
  More professional, AWS handles DB backups
  ⭐ Move to this after learning
```

---

## 2. AWS Services and Cost

| Service | Plan | Cost |
|---|---|---|
| EC2 t2.micro | Free tier | FREE for 12 months (750 hrs/month) |
| RDS db.t3.micro | Free tier | FREE for 12 months (750 hrs/month) |
| Parameter Store Standard | Always free | FREE forever |
| Elastic IP | Free when attached | FREE (charged if not attached) |
| Data transfer | First 1GB/month | FREE |

```
⚠️  IMPORTANT WARNINGS:
1. Free tier = 12 months only for EC2 and RDS
2. After 12 months → ~$15-20/month
3. STOP instances when not using to save hours
4. DELETE everything when done learning
5. Set billing alerts in AWS Console!
```

### Set billing alert (do this first!)
```
AWS Console → Billing → Budgets → Create Budget
  Budget type: Cost budget
  Amount: $5
  Alert: when actual cost > $4
  Email: your email
→ This protects you from surprise bills!
```

---

## 3. Step 1 — AWS Account Setup

```
1. Go to https://aws.amazon.com → Create account
2. Add credit/debit card (required but not charged in free tier)
3. Complete phone verification
4. Select Support plan: Basic (FREE)
5. Sign in to AWS Management Console
6. Select region: ap-south-1 (Mumbai — closest to Hyderabad)
   → Top right dropdown → Asia Pacific (Mumbai)
```

---

## 4. Step 2 — Create EC2 Instance

```
AWS Console → EC2 → Launch Instance

── Basic Settings ──────────────────────────────
Name: student-app-server
AMI:  Ubuntu Server 22.04 LTS ← free tier eligible
      (DO NOT select Windows — expensive)

Instance type: t2.micro ← free tier eligible
               (1 vCPU, 1GB RAM — enough for learning)

── Key Pair ─────────────────────────────────────
→ Create new key pair
  Name: student-app-key
  Key pair type: RSA
  Private key format: .pem (for Linux/Mac)
  → Download student-app-key.pem
  ⚠️  SAVE THIS FILE SAFELY — you cannot download again!

── Network Settings ──────────────────────────────
VPC: default
✅ Allow SSH traffic (port 22) — from anywhere
✅ Allow HTTP (port 80)
✅ Allow HTTPS (port 443)

── Storage ───────────────────────────────────────
20 GiB gp3 (free tier gives 30GB)

→ Launch Instance
```

### Add port 8081 to Security Group (REQUIRED!)
```
EC2 → Security Groups → Find your instance's security group
→ Inbound rules → Edit inbound rules → Add rule
  Type: Custom TCP
  Port range: 8081
  Source: 0.0.0.0/0 (anywhere)
  Description: Spring Boot App
→ Save rules ✅
```

### Assign Elastic IP (optional but recommended)
```
Without Elastic IP: EC2 public IP changes every time you stop/start!
With Elastic IP: Fixed IP address forever (free when instance is running)

EC2 → Elastic IPs → Allocate Elastic IP address → Allocate
→ Select the new IP → Actions → Associate Elastic IP
→ Select your instance → Associate ✅

Now your IP never changes!
```

---

## 5. Step 3 — Connect via SSH

```bash
# On your LOCAL machine (not EC2)

# Step 1: Move key to safe location
mv ~/Downloads/student-app-key.pem ~/.ssh/
chmod 400 ~/.ssh/student-app-key.pem
# chmod 400 = read only for owner — SSH requires this!

# Step 2: Get EC2 Public IP
# EC2 → Instances → your instance → Public IPv4 address
# Example: 13.233.xxx.xxx

# Step 3: Connect
ssh -i ~/.ssh/student-app-key.pem ubuntu@13.233.xxx.xxx
# ubuntu = default username for Ubuntu AMI
# First time: type "yes" to accept fingerprint

# Success! Prompt changes to:
# ubuntu@ip-172-xx-xx-xx:~$
# You are now INSIDE your EC2 server!
```

### Create SSH shortcut (optional — saves typing)
```bash
# Add to ~/.ssh/config on your LOCAL machine
nano ~/.ssh/config

# Add these lines:
Host student-ec2
  HostName 13.233.xxx.xxx
  User ubuntu
  IdentityFile ~/.ssh/student-app-key.pem

# Now connect with just:
ssh student-ec2

# Copy files with:
scp -r ./app student-ec2:~/
```

---

## 6. Step 4 — Install Docker on EC2

Run all these commands INSIDE EC2 (after SSH):

```bash
# Update package list
sudo apt-get update

# Install Docker and Docker Compose plugin
sudo apt-get install -y docker.io docker-compose-plugin

# Start Docker service
sudo systemctl start docker

# Auto-start Docker on server reboot
sudo systemctl enable docker

# Add ubuntu user to docker group (no sudo needed)
sudo usermod -aG docker ubuntu
newgrp docker

# ── Fix DNS (IMPORTANT — same as local!) ──────────────
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
EOF

# Restart Docker to apply DNS fix
sudo systemctl restart docker

# ── Verify everything works ───────────────────────────
docker --version
docker compose version
docker run hello-world
# Expected: Hello from Docker! ✅

# Install AWS CLI (needed to read Parameter Store)
sudo apt-get install -y awscli

# Verify AWS CLI
aws --version
```

---

## 7. Step 5 — Parameter Store

Go to **AWS Console → Systems Manager → Parameter Store**

Create each parameter:

```
Click: Create parameter

Parameter 1 — DB Username:
  Name:  /student-app/prod/DB_USERNAME
  Tier:  Standard (FREE)
  Type:  String
  Value: postgres
  → Create parameter ✅

Parameter 2 — DB Password:
  Name:  /student-app/prod/DB_PASSWORD
  Tier:  Standard (FREE)
  Type:  SecureString  ← encrypted with KMS, FREE!
  Value: yourStrongPassword123
  → Create parameter ✅

Parameter 3 — JWT Secret:
  Name:  /student-app/prod/JWT_SECRET
  Tier:  Standard (FREE)
  Type:  SecureString
  Value: myProductionSecretKey12345678901234
  → Create parameter ✅

Parameter 4 — DB URL (Approach A — Docker local DB):
  Name:  /student-app/prod/DB_URL
  Tier:  Standard
  Type:  String
  Value: jdbc:postgresql://postgres-db:5432/studentdb
  → Create parameter ✅

Parameter 4 — DB URL (Approach B — RDS):
  Name:  /student-app/prod/DB_URL
  Tier:  Standard
  Type:  String
  Value: jdbc:postgresql://student-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com:5432/studentdb
  → Create parameter ✅
```

### Test from EC2 (after IAM role attached)
```bash
# Inside EC2 — test reading parameter
aws ssm get-parameter \
  --name "/student-app/prod/DB_USERNAME" \
  --region ap-south-1

# Test reading SecureString (with decryption)
aws ssm get-parameter \
  --name "/student-app/prod/DB_PASSWORD" \
  --region ap-south-1 \
  --with-decryption
```

---

## 8. Step 6 — IAM Role

IAM Role = permission card for your EC2 to read Parameter Store.
Without this, EC2 can't read your secrets!

```
AWS Console → IAM → Roles → Create role

Step 1: Trusted entity
  → AWS service → EC2 → Next

Step 2: Add permissions
  → Search: SSMReadOnlyAccess
  → Select: AmazonSSMReadOnlyAccess ✅
  → Next

Step 3: Name and create
  Role name: student-app-ec2-role
  → Create role ✅

Step 4: Attach to EC2 instance
  EC2 → Instances → select your instance
  → Actions → Security → Modify IAM role
  → Select: student-app-ec2-role
  → Update IAM role ✅
```

Now EC2 can read Parameter Store automatically — no passwords needed!

---

## 9. Step 7A — Deploy with Docker (Approach A)

### Files needed on EC2
```
~/app/
├── Dockerfile
├── docker-compose.prod.yml
├── Dockerfile.ec2
├── fetch-params.sh
└── target/
    └── Student-0.0.1-SNAPSHOT.jar
```

### On LOCAL machine — build and copy files

```bash
# Build JAR
cd ~/Documents/Rathi/Student
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 ./mvnw clean package -DskipTests

# Create app folder on EC2
ssh student-ec2 "mkdir -p ~/app/target"

# Copy JAR to EC2
scp -i ~/.ssh/student-app-key.pem \
  target/Student-0.0.1-SNAPSHOT.jar \
  ubuntu@13.233.xxx.xxx:~/app/target/

# Copy Dockerfile
scp -i ~/.ssh/student-app-key.pem \
  Dockerfile \
  ubuntu@13.233.xxx.xxx:~/app/
```

### `Dockerfile.ec2` — create on EC2

```bash
cat > ~/app/Dockerfile.ec2 << 'EOF'
# No build stage needed — JAR already built locally!
# Just take the JAR and run it
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy the JAR that is already in this folder
COPY Student-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=docker"]
EOF
```

### `docker-compose.prod.yml` — create on EC2

SSH into EC2, then:
```bash
cat > ~/app/docker-compose.prod.yml << 'EOF'
services:

  postgres-db:
    image: postgres:15-alpine
    container_name: student-postgres
    restart: always
    environment:
      POSTGRES_DB: studentdb
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  student-app:
    image: student-app:latest
    container_name: student-app
    restart: always
    ports:
      - "8081:8081"
    environment:
      DB_URL: jdbc:postgresql://postgres-db:5432/studentdb
      DB_USERNAME: ${DB_USERNAME}
      DB_PASSWORD: ${DB_PASSWORD}
      JWT_SECRET: ${JWT_SECRET}
      JWT_EXPIRATION: 86400000
    depends_on:
      postgres-db:
        condition: service_healthy

volumes:
  postgres_data:
EOF
```

### `fetch-params.sh` — create on EC2

```bash
cat > ~/app/fetch-params.sh << 'EOF'
#!/bin/bash
echo "Fetching secrets from AWS Parameter Store..."

export DB_URL=$(aws ssm get-parameter \
  --name "/student-app/prod/DB_URL" \
  --region ap-south-2 \
  --query "Parameter.Value" \
  --output text)

export DB_USERNAME=$(aws ssm get-parameter \
  --name "/student-app/prod/DB_USERNAME" \
  --region ap-south-1 \
  --query "Parameter.Value" \
  --output text)

export DB_PASSWORD=$(aws ssm get-parameter \
  --name "/student-app/prod/DB_PASSWORD" \
  --region ap-south-1 \
  --with-decryption \
  --query "Parameter.Value" \
  --output text)

export JWT_SECRET=$(aws ssm get-parameter \
  --name "/student-app/prod/JWT_SECRET" \
  --region ap-south-1 \
  --with-decryption \
  --query "Parameter.Value" \
  --output text)

echo "DB_USERNAME loaded: $DB_USERNAME"
echo "DB_URL: $DB_URL"
echo "DB_PASSWORD loaded: [hidden]"
echo "JWT_SECRET loaded: [hidden]"
echo "All secrets loaded successfully!"
EOF

chmod +x ~/app/fetch-params.sh
```

### Build and Run on EC2

```bash
# SSH into EC2
ssh -i ~/.ssh/student-app-key.pem ubuntu@13.233.xxx.xxx

cd ~/app

# Build Docker image from JAR
docker build -t student-app:latest .  # We got the error using this commands

# Run the beolw commands 
docker build -f Dockerfile.ec2 -t student-app:latest .

# Load secrets from Parameter Store
source fetch-params.sh

# Start containers
docker compose -f docker-compose.prod.yml up -d

# Check status
docker compose -f docker-compose.prod.yml ps

# Watch logs
docker compose -f docker-compose.prod.yml logs -f student-app
```

---

## 10. Step 7B — Deploy with RDS (Approach B)

### Create RDS PostgreSQL

```
AWS Console → RDS → Create database

Engine: PostgreSQL
Version: PostgreSQL 15.x
Template: Free tier  ← IMPORTANT!

Settings:
  DB instance identifier: student-db
  Master username: postgres
  Master password: yourStrongPassword123

Instance configuration:
  DB instance class: db.t3.micro  ← free tier

Storage:
  20 GiB  ← free tier gives 20GB

Connectivity:
  VPC: default
  Public access: Yes
  Security group: Create new → name: student-db-sg

→ Create database (takes 5-10 minutes)

After created — copy the endpoint:
  student-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com
```

### Allow EC2 to connect to RDS

```
RDS → Databases → student-db
→ Connectivity & security → Security groups → student-db-sg
→ Inbound rules → Edit → Add rule:
  Type: PostgreSQL
  Port: 5432
  Source: select your EC2 security group
→ Save ✅
```

### Update Parameter Store DB_URL

```
Parameter Store → /student-app/prod/DB_URL → Edit
New value: jdbc:postgresql://student-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com:5432/postgres

example :- jdbc:postgresql://database-1.cb0k4geqowjf.ap-south-2.rds.amazonaws.com:5432/postgres
→ Save ✅
```

### `application-prod.properties`

```properties
# src/main/resources/application-prod.properties
spring.application.name=Student
server.port=8081

spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false

jwt.secret=${JWT_SECRET}
jwt.expiration=86400000

springdoc.api-docs.enabled=true
springdoc.swagger-ui.enabled=true
springdoc.swagger-ui.path=/swagger-ui.html

logging.level.org.example.student=INFO
logging.level.org.springframework=WARN
```

### `Dockerfile.prod` — uses prod profile

```dockerfile
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=prod"]
```

### `docker-compose.rds.yml` — app only, no postgres container

```yaml
services:
  student-app:
    image: student-app:prod
    container_name: student-app
    restart: always
    ports:
      - "8081:8081"
    environment:
      DB_URL: ${DB_URL}
      DB_USERNAME: ${DB_USERNAME}
      DB_PASSWORD: ${DB_PASSWORD}
      JWT_SECRET: ${JWT_SECRET}
      JWT_EXPIRATION: 86400000
```

### Deploy on EC2 with RDS

```bash
ssh student-ec2
cd ~/app

# Load secrets (now includes RDS URL)
source fetch-params.sh

# Build with prod profile
docker build -f Dockerfile.prod -t student-app:prod .

# Start only app (no postgres container — using RDS!)
docker compose -f docker-compose.rds.yml up -d

# Check logs
docker compose -f docker-compose.rds.yml logs -f
```

# Check in your ec2 server Rds data is come or not run the below commands :-

# From EC2 — test RDS connection
# Install postgresql client
sudo apt-get install -y postgresql-client

# Connect to RDS and see what databases exist
psql -h database-1.cb0k4geqowjf.ap-south-2.rds.amazonaws.com \
     -U postgres \
     -p 5432 \
     -c "\l"
# Enter your RDS password when prompted

# \l = list all databases
# Look for the actual DB name!

---

## 11. Step 8 — Test Live API

```bash
# Replace with your actual EC2 IP
EC2_IP=13.233.xxx.xxx

# Test: Register
curl -X POST http://$EC2_IP:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123","role":"ADMIN"}'

# Test: Login
curl -X POST http://$EC2_IP:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'

# Test: Swagger UI (open in browser)
http://13.233.xxx.xxx:8081/swagger-ui/index.html
```

---

## 12. Auto-Start on Reboot

```bash
# Inside EC2 — create systemd service
sudo tee /etc/systemd/system/student-app.service << 'EOF'
[Unit]
Description=Student App Docker Compose
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/app
ExecStartPre=/bin/bash /home/ubuntu/app/fetch-params.sh
ExecStart=/usr/bin/docker compose -f docker-compose.prod.yml up -d
ExecStop=/usr/bin/docker compose -f docker-compose.prod.yml down
User=ubuntu

[Install]
WantedBy=multi-user.target
EOF

# Enable service (auto-start on boot)
sudo systemctl enable student-app

# Start now
sudo systemctl start student-app

# Check status
sudo systemctl status student-app
```

---

## 13. Update App — New Version

When you make code changes and want to redeploy:

```bash
# ── On LOCAL machine ─────────────────────────────────────
cd ~/Documents/Rathi/Student

# Build new JAR
./mvnw clean package -DskipTests

# Copy to EC2
scp -i ~/.ssh/student-app-key.pem \
  target/Student-0.0.1-SNAPSHOT.jar \
  ubuntu@13.233.xxx.xxx:~/app/target/

# ── On EC2 (SSH in) ───────────────────────────────────────
ssh student-ec2
cd ~/app

# Stop old container
docker compose -f docker-compose.prod.yml down

# Rebuild image with new JAR
docker build -t student-app:latest .

# Reload secrets
source fetch-params.sh

# Start new container
docker compose -f docker-compose.prod.yml up -d

# Verify new version is running
docker compose -f docker-compose.prod.yml logs -f student-app
```

---

## 14. Common Errors and Fixes

### Error: SSH permission denied
```
Error: Permissions 0644 for 'student-app-key.pem' are too open

Fix: chmod 400 ~/.ssh/student-app-key.pem
```

### Error: Connection refused on port 8081
```
Cause: Security Group not allowing port 8081

Fix:
  EC2 → Security Groups → Inbound rules → Edit
  Add: Custom TCP, Port 8081, Source 0.0.0.0/0
```

### Error: App can't read Parameter Store
```
Error: An error occurred (AccessDeniedException)

Cause: IAM role not attached to EC2 or wrong permissions

Fix:
  1. Check IAM role: EC2 → Actions → Security → Modify IAM role
  2. Role must have AmazonSSMReadOnlyAccess
  3. Test: aws ssm get-parameter --name "/student-app/prod/DB_USERNAME" --region ap-south-1
```

### Error: Can't connect to RDS
```
Error: Connection refused to RDS endpoint

Cause 1: RDS Security Group not allowing EC2
Fix: RDS security group inbound → add PostgreSQL rule for EC2 security group

Cause 2: RDS not publicly accessible
Fix: RDS → Modify → Connectivity → Public access: Yes

Cause 3: Wrong endpoint in Parameter Store
Fix: Check RDS endpoint exactly — copy from RDS console
```

### Error: Docker DNS issues on EC2
```
Error: dial tcp: lookup registry-1.docker.io: server misbehaving

Fix: Same as local!
  sudo nano /etc/docker/daemon.json
  Add: {"dns": ["8.8.8.8", "8.8.4.4"]}
  sudo systemctl restart docker
```

### Error: Port 8081 already in use on EC2
```
Fix: sudo fuser -k 8081/tcp
```

### Error: Out of memory on t2.micro
```
Cause: t2.micro has only 1GB RAM
       Spring Boot + PostgreSQL = ~800MB

Fix: Add swap space
  sudo fallocate -l 1G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## 15. Cost Management

```bash
# ── ALWAYS DO THIS: Set billing alert ─────────────────
AWS Console → Billing and Cost Management → Budgets
→ Create budget → Cost budget
  Amount: $5
  Alert at: $4 actual cost
  Email: your-email@example.com
→ Create ✅

# ── Stop instances when not using ─────────────────────
EC2: AWS Console → EC2 → Instances → Instance State → Stop
RDS: AWS Console → RDS → Databases → Actions → Stop temporarily

# Note: Stopped EC2 = no compute charge
#       But storage still costs (very small amount)
#       Elastic IP without running instance = small charge!

# ── Delete everything when done learning ──────────────
EC2:           Terminate instance (not just stop!)
RDS:           Delete database (create final snapshot if needed)
Elastic IP:    Release address
Security Groups: Delete
Parameter Store: Delete parameters
IAM Roles:     Delete

# When everything is deleted → zero charges! ✅
```

---

## 16. Quick Checklist

### AWS Setup
- [ ] AWS account created
- [ ] Billing alert set ($5 limit)
- [ ] Region set to ap-south-1 (Mumbai)

### EC2
- [ ] t2.micro Ubuntu 22.04 instance launched
- [ ] Key pair downloaded and secured (`chmod 400`)
- [ ] Security group has port 22, 80, 443, 8081 open
- [ ] Elastic IP assigned (optional but recommended)
- [ ] SSH connection working

### EC2 Software
- [ ] Docker installed and running
- [ ] Docker compose working
- [ ] DNS fix applied (`/etc/docker/daemon.json`)
- [ ] AWS CLI installed
- [ ] `docker run hello-world` works ✅

### Parameter Store
- [ ] `/student-app/prod/DB_USERNAME` created
- [ ] `/student-app/prod/DB_PASSWORD` created (SecureString)
- [ ] `/student-app/prod/JWT_SECRET` created (SecureString)
- [ ] `/student-app/prod/DB_URL` created

### IAM Role
- [ ] Role `student-app-ec2-role` created
- [ ] `AmazonSSMReadOnlyAccess` policy attached
- [ ] Role attached to EC2 instance
- [ ] Test: `aws ssm get-parameter --name "/student-app/prod/DB_USERNAME"` works ✅

### Deployment (Approach A)
- [ ] JAR built locally
- [ ] JAR copied to EC2
- [ ] Dockerfile copied to EC2
- [ ] `docker-compose.prod.yml` created on EC2
- [ ] `fetch-params.sh` created and executable on EC2
- [ ] Docker image built on EC2
- [ ] Containers running: `docker compose ps` shows `Up`
- [ ] API works: `curl http://EC2-IP:8081/api/auth/register`
- [ ] Swagger works in browser ✅

### Auto-start
- [ ] systemd service created
- [ ] Service enabled: `sudo systemctl enable student-app`
- [ ] Test: reboot EC2 → app comes back automatically

---

## Profile Summary

| Environment | Command | Properties file | DB location |
|---|---|---|---|
| Local dev | `mvn spring-boot:run` | `application.properties` | Local PostgreSQL |
| Docker local | `docker compose up` | `application-docker.properties` | Docker container |
| AWS Approach A | `docker compose -f docker-compose.prod.yml up` | `application-docker.properties` | Docker container on EC2 |
| AWS Approach B | `docker compose -f docker-compose.rds.yml up` | `application-prod.properties` | AWS RDS |

---

*Phase 5 Complete! Your app is live on the internet! 🚀*
*Next: Phase 6 — CI/CD with GitHub Actions (auto-deploy on git push)*
