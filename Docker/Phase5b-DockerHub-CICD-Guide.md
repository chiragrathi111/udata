# Phase 5b — Docker Hub + CI/CD Guide
## Local → Docker Hub → EC2 (Industry Standard Way)

---

## Table of Contents
1. [Why Docker Hub](#1-why-docker-hub)
2. [Current vs Industry Way](#2-current-vs-industry-way)
3. [Step 1 — Create Docker Hub Account](#3-step-1--create-docker-hub-account)
4. [Step 2 — Dockerfile for Production](#4-step-2--dockerfile-for-production)
5. [Step 3 — Build and Push to Docker Hub](#5-step-3--build-and-push-to-docker-hub)
6. [Step 4 — Update docker-compose on EC2](#6-step-4--update-docker-compose-on-ec2)
7. [Step 5 — Deploy on EC2](#7-step-5--deploy-on-ec2)
8. [Step 6 — deploy.sh One Command Deploy](#8-step-6--deploysh-one-command-deploy)
9. [Step 7 — Update App New Version](#9-step-7--update-app-new-version)
10. [Step 8 — GitHub Actions CI/CD](#10-step-8--github-actions-cicd)
11. [Common Errors and Fixes](#11-common-errors-and-fixes)
12. [Docker Hub Commands Reference](#12-docker-hub-commands-reference)
13. [Quick Checklist](#13-quick-checklist)

---

## 1. Why Docker Hub

### The problem with copying JAR manually
```
Current manual way:
  1. Build JAR on laptop
  2. scp JAR to EC2  ← manual, error prone
  3. Build image on EC2 ← slow, wastes EC2 resources
  4. Run container

Problems:
  ❌ EC2 needs to build every time (slow)
  ❌ Manual file copying (forget steps easily)
  ❌ No version history of images
  ❌ If EC2 crashes → image is gone
  ❌ Team members can't share the image
  ❌ Not automatable
```

### Docker Hub solves all of this
```
Industry way:
  1. Build JAR on laptop
  2. Build Docker image on laptop
  3. Push image to Docker Hub ← like GitHub but for images
  4. EC2 pulls image from Docker Hub
  5. Run container

Benefits:
  ✅ EC2 never needs source code or JAR
  ✅ One command deploy on EC2
  ✅ Version history (v1.0, v1.1, v1.2...)
  ✅ Team members pull same image anywhere
  ✅ Works with CI/CD (GitHub Actions)
  ✅ Industry standard — used everywhere
  ✅ Free for public images
```

---

## 2. Current vs Industry Way

```
YOUR CURRENT WAY:
─────────────────
Laptop                    EC2
──────                    ───
mvn package               
scp JAR ─────────────→   receives JAR
                          docker build  ← builds on server (slow!)
                          docker run

INDUSTRY WAY (Docker Hub):
──────────────────────────
Laptop          Docker Hub          EC2
──────          ──────────          ───
mvn package
docker build
docker push ──→ image stored   ←── docker pull
                (like GitHub        docker run
                 but for images)

BEST WAY (CI/CD — fully automatic):
────────────────────────────────────
git push
    ↓
GitHub Actions:
  mvn package
  docker build
  docker push ──→ Docker Hub ←── docker pull
                                  docker run
    ↓
App live! Zero manual steps! 🚀
```

---

## 3. Step 1 — Create Docker Hub Account

```
1. Go to: https://hub.docker.com
2. Sign Up
   Username: chiragrathi  ← remember this, used in all commands
   Email: your email
   Password: strong password

3. Verify email

4. Create Repository:
   → Repositories → Create Repository
   → Name: student-app
   → Visibility: Public (Free) ← use this for learning
   → Description: Spring Boot Student CRUD API
   → Create ✅

Your image name will be: chiragrathi/student-app
```

---

## 4. Step 2 — Dockerfile for Production

Create `Dockerfile.ec2` in your project root on LOCAL machine:

```dockerfile
# Dockerfile.ec2
# Simple production Dockerfile
# JAR is built locally → just needs to run it
# No Maven, no source code needed → small image!

FROM eclipse-temurin:17-jre-alpine

# Working directory inside container
WORKDIR /app

# Copy the pre-built JAR
COPY target/Student-0.0.1-SNAPSHOT.jar app.jar

# Expose port
EXPOSE 8081

# Run with prod profile
# prod profile → uses application-prod.properties
# reads DB_URL, JWT_SECRET etc from environment variables
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=prod"]
```

### application-prod.properties (src/main/resources/)
```properties
# Used when --spring.profiles.active=prod
spring.application.name=Student
server.port=8081

# Values come from docker-compose environment section
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

---

## 5. Step 3 — Build and Push to Docker Hub

Run all these on your **LOCAL machine**:

```bash
# ── Step 1: Login to Docker Hub ──────────────────────────
docker login
# Username: chiragrat
# Password: your Docker Hub password
# Login Succeeded ✅

# ── Step 2: Build JAR ────────────────────────────────────
cd ~/Documents/Rathi/Student

JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
  ./mvnw clean package -DskipTests

# Verify JAR exists
ls target/*.jar
# target/Student-0.0.1-SNAPSHOT.jar ✅

# ── Step 3: Build Docker image ───────────────────────────
# Format: yourusername/imagename:tag
docker build -f Dockerfile.ec2 -t chiragrat/student-app:latest .

# Also tag with version number (good practice!)
docker tag chiragrat/student-app:latest chiragrathi/student-app:v1.0

# Verify image created
docker images | grep student-app
# chiragrat/student-app   latest   xxxxx   2 min ago   xxx MB
# chiragrat/student-app   v1.0     xxxxx   2 min ago   xxx MB

# ── Step 4: Push to Docker Hub ───────────────────────────
docker push chiragrat/student-app:latest
docker push chiragrat/student-app:v1.0

# Check Docker Hub in browser:
# https://hub.docker.com/r/chiragrathi/student-app
# Your image is now publicly available! ✅
```

### Image naming convention
```
chiragrat/student-app:latest   ← always the newest version
chiragrat/student-app:v1.0     ← version 1.0 (stays forever)
chiragrat/student-app:v1.1     ← version 1.1
chiragrat/student-app:v2.0     ← major update

Why version tags?
  latest = can change → EC2 always gets newest
  v1.0   = never changes → can rollback if new version breaks!

Rollback example:
  docker pull chiragrat/student-app:v1.0  ← go back to old version
```

---

## 6. Step 4 — Update docker-compose on EC2

SSH into EC2 and update `docker-compose.rds.yml`:

```bash
ssh -i ~/.ssh/student-app-key.pem ubuntu@YOUR_EC2_IP
nano ~/app/docker-compose.rds.yml
```

```yaml
# docker-compose.rds.yml
# Uses Docker Hub image — no build needed on EC2!

services:
  student-app:
    image: chiragrathi/student-app:latest
    # ↑ Docker Hub image — pulled automatically!
    # EC2 never needs JAR or source code!
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

---

## 7. Step 5 — Deploy on EC2

```bash
# SSH into EC2
ssh -i ~/.ssh/student-app-key.pem ubuntu@YOUR_EC2_IP

cd ~/app

# Load secrets from Parameter Store
source fetch-params.sh

# Pull latest image from Docker Hub
docker pull chiragrathi/student-app:latest

# Stop old container
docker compose -f docker-compose.rds.yml down

# Start with new image
docker compose -f docker-compose.rds.yml up -d

# Check it's running
docker compose -f docker-compose.rds.yml ps

# Watch logs
docker compose -f docker-compose.rds.yml logs -f student-app

# Test API
curl -X POST http://localhost:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123","role":"ADMIN"}'

# From your laptop (use EC2 public IP)
curl -X POST http://YOUR_EC2_IP:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123","role":"ADMIN"}'
```

---

## 8. Step 6 — deploy.sh One Command Deploy

Create this on EC2 — deploy with just one command!

```bash
cat > ~/app/deploy.sh << 'EOF'
#!/bin/bash

echo "========================================"
echo "Starting deployment..."
echo "========================================"

# Load secrets from Parameter Store
echo "Loading secrets from AWS Parameter Store..."
source /home/ubuntu/app/fetch-params.sh

# Pull latest image from Docker Hub
echo "Pulling latest image from Docker Hub..."
docker pull chiragrathi/student-app:latest

# Stop old container
echo "Stopping old container..."
docker compose -f /home/ubuntu/app/docker-compose.rds.yml down

# Start new container with fresh image
echo "Starting new container..."
docker compose -f /home/ubuntu/app/docker-compose.rds.yml up -d

# Wait for app to start
echo "Waiting for app to start..."
sleep 10

# Show status
echo "========================================"
echo "Deployment complete!"
echo "========================================"
docker compose -f /home/ubuntu/app/docker-compose.rds.yml ps

# Quick health check
echo "Health check:"
curl -s -o /dev/null -w "API Status: %{http_code}\n" \
  http://localhost:8081/api/auth/login \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test"}'
EOF

# Make executable
chmod +x ~/app/deploy.sh

# Deploy with ONE command!
~/app/deploy.sh
```

---

## 9. Step 7 — Update App New Version

When you make code changes:

### On LOCAL machine
```bash
# Step 1: Make your code changes in IntelliJ

# Step 2: Build new JAR
cd ~/Documents/Rathi/Student
./mvnw clean package -DskipTests

# DO NOT add target/ here!
# target/ must be accessible for COPY command in Dockerfile
# Remove in .dockerignore

# Step 3: Build new Docker image
docker build -f Dockerfile.ec2 -t chiragrat/student-app:v1.1 .
docker tag chiragrat/student-app:v1.1 chiragrat/student-app:latest

# Step 4: Push to Docker Hub
docker push chiragrat/student-app:latest
docker push chiragrat/student-app:v1.1

echo "Image pushed to Docker Hub! ✅"
```

### On EC2 — just ONE command!
```bash
ssh -i ~/.ssh/student-app-key.pem ubuntu@YOUR_EC2_IP
~/app/deploy.sh

# That's it! New version is live! 🚀
```

### Version history on Docker Hub
```
https://hub.docker.com/r/chiragrathi/student-app/tags

Tags:
  latest  ← always newest
  v1.0    ← first version
  v1.1    ← second version (new features)
  v1.2    ← bug fix
```

### Rollback to previous version
```bash
# If v1.1 has a bug → rollback to v1.0

# On EC2:
docker compose -f docker-compose.rds.yml down
docker pull chiragrat/student-app:v1.0
# Edit docker-compose.rds.yml → change latest to v1.0
docker compose -f docker-compose.rds.yml up -d
# Old version is back in 30 seconds! ✅
```

---

## 10. Step 8 — GitHub Actions CI/CD

### What is CI/CD?
```
CI = Continuous Integration  → automatically build + test on every push
CD = Continuous Deployment   → automatically deploy to server

git push → GitHub Actions runs → build → test → push to Docker Hub → deploy to EC2
Zero manual steps after git push! 🚀
```

### Create workflow file
Create `.github/workflows/deploy.yml` in your project:

```yaml
name: Build, Push and Deploy

# Trigger: runs on every push to main branch
on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest  # GitHub provides this free runner

    steps:

      # ── Step 1: Get source code ──────────────────────────
      - name: Checkout code
        uses: actions/checkout@v3

      # ── Step 2: Setup Java 17 ────────────────────────────
      - name: Set up Java 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'

      # ── Step 3: Cache Maven dependencies ─────────────────
      # Downloads faster next time (cached)
      - name: Cache Maven packages
        uses: actions/cache@v3
        with:
          path: ~/.m2
          key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}

      # ── Step 4: Build JAR ─────────────────────────────────
      - name: Build JAR with Maven
        run: ./mvnw clean package -DskipTests

      # ── Step 5: Login to Docker Hub ──────────────────────
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
          # These come from GitHub Secrets (next section)

      # ── Step 6: Build and push Docker image ──────────────
      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          file: ./Dockerfile.ec2
          push: true
          tags: |
            chiragrathi/student-app:latest
            chiragrathi/student-app:v${{ github.run_number }}
            # v1, v2, v3... auto-increments with each push!

      # ── Step 7: Deploy to EC2 ────────────────────────────
      - name: Deploy to EC2
        uses: appleboy/ssh-action@v0.1.8
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ubuntu
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            cd ~/app
            ~/app/deploy.sh
```

### Add GitHub Secrets (IMPORTANT!)
```
GitHub → Your repository → Settings → Secrets and variables
→ Actions → New repository secret

Add these 4 secrets:

Secret 1:
  Name:  DOCKER_USERNAME
  Value: chiragrathi  ← your Docker Hub username

Secret 2:
  Name:  DOCKER_PASSWORD
  Value: your Docker Hub password or access token

Secret 3:
  Name:  EC2_HOST
  Value: 13.233.xxx.xxx  ← your EC2 public IP

Secret 4:
  Name:  EC2_SSH_KEY
  Value: paste entire contents of student-app-key.pem file
         Including: -----BEGIN RSA PRIVATE KEY----- line!
```

### How to get EC2_SSH_KEY value
```bash
# On your LOCAL machine
cat ~/.ssh/student-app-key.pem

# Copy everything including:
# -----BEGIN RSA PRIVATE KEY-----
# MIIEpAIBAAKCAQEA...
# ...many lines...
# -----END RSA PRIVATE KEY-----
# Paste this entire thing as EC2_SSH_KEY secret
```

### After setup — test it!
```bash
# Make any small change to your code
# Then:
git add .
git commit -m "test: trigger CI/CD pipeline"
git push origin main

# Go to GitHub → Actions tab
# Watch pipeline run automatically!
# In 3-5 minutes → new version is live on EC2! 🚀
```

---

## 11. Common Errors and Fixes

### Error: docker login failed
```
Error: unauthorized: incorrect username or password

Fix:
  1. Check username/password on hub.docker.com
  2. Create Access Token instead of password:
     Docker Hub → Account Settings → Security → New Access Token
     Use token as password in docker login
```

### Error: denied: requested access to the resource is denied
```
Error: denied: requested access to the resource is denied

Cause: Image name doesn't match your Docker Hub username
Fix:   Make sure image name = yourusername/imagename
       docker build -t chiragrat/student-app:latest .
                       ↑ must match your Docker Hub username!
```

### Error: DB_URL variable is not set
```
Error: WARN The "DB_URL" variable is not set. Defaulting to a blank string.

Cause 1: fetch-params.sh not run before docker compose
Fix:     source ~/app/fetch-params.sh (note: source not bash!)

Cause 2: Wrong AWS region in fetch-params.sh
Fix:     Check your region — ap-south-1 or ap-south-2?
         ARN in Parameter Store shows the region!
         arn:aws:ssm:ap-south-2:... → use ap-south-2

Cause 3: IAM role not attached to EC2
Fix:     EC2 → Actions → Security → Modify IAM role
         Attach AmazonSSMReadOnlyAccess
```

### Error: GitHub Actions — SSH connection failed
```
Error: ssh: handshake failed

Fix 1: Check EC2_HOST is correct IP
Fix 2: EC2 Security Group must allow port 22 from anywhere
Fix 3: EC2_SSH_KEY must include full key with header/footer lines
       -----BEGIN RSA PRIVATE KEY----- ← must be included!
Fix 4: Make sure EC2 instance is running
```

### Error: image not found on Docker Hub
```
Error: Unable to find image 'chiragrat/student-app:latest' locally
       Error response from daemon: pull access denied

Cause 1: Image not pushed yet → run docker push first
Cause 2: Repository is private → make it public or login on EC2
Fix:     docker login on EC2 first, then docker pull
```

### Error: docker push — timeout
```
Error: timeout or connection refused during docker push

Cause: Slow internet or Docker Hub is down
Fix:
  1. Check https://status.docker.com
  2. Try again after some time
  3. Check your internet connection
```

### Error: old image still running after deploy
```
Cause: Docker cached the old image

Fix:
  docker compose -f docker-compose.rds.yml down
  docker image rm chiragrat/student-app:latest  ← force remove old
  docker pull chiragrat/student-app:latest       ← fresh pull
  docker compose -f docker-compose.rds.yml up -d
```

---

## 12. Docker Hub Commands Reference

```bash
# ── Authentication ────────────────────────────────────────
docker login                              # login to Docker Hub
docker logout                             # logout

# ── Build image ───────────────────────────────────────────
docker build -t username/imagename:tag .  # build with tag
docker build -f Dockerfile.ec2 -t username/imagename:latest .  # specific Dockerfile

# ── Tag image ─────────────────────────────────────────────
docker tag source:tag target:newtag       # create new tag from existing

# ── Push to Docker Hub ────────────────────────────────────
docker push username/imagename:latest     # push latest
docker push username/imagename:v1.0       # push specific version

# ── Pull from Docker Hub ──────────────────────────────────
docker pull username/imagename:latest     # pull latest
docker pull username/imagename:v1.0       # pull specific version

# ── List images ───────────────────────────────────────────
docker images                             # all local images
docker images | grep student-app          # filter by name

# ── Remove images ─────────────────────────────────────────
docker image rm username/imagename:tag    # remove specific
docker image prune                        # remove dangling images
docker system prune -a                    # remove everything unused
```

---

## 13. Quick Checklist

### Docker Hub Setup
- [ ] Docker Hub account created at hub.docker.com
- [ ] Repository `student-app` created (public)
- [ ] `docker login` works on local machine ✅

### Local Build
- [ ] `Dockerfile.ec2` created in project root
- [ ] `application-prod.properties` created
- [ ] JAR built: `./mvnw clean package -DskipTests`
- [ ] Image built: `docker build -f Dockerfile.ec2 -t chiragrathi/student-app:latest .`
- [ ] Image pushed: `docker push chiragrathi/student-app:latest` ✅
- [ ] Image visible on hub.docker.com ✅

### EC2 Setup
- [ ] `docker-compose.rds.yml` updated to use Docker Hub image
- [ ] `fetch-params.sh` has correct region (ap-south-2)
- [ ] `deploy.sh` created and executable (`chmod +x`)
- [ ] `source fetch-params.sh` works (shows DB_USERNAME etc)
- [ ] `docker pull chiragrathi/student-app:latest` works ✅
- [ ] `~/app/deploy.sh` runs successfully ✅
- [ ] API accessible from public IP: `http://EC2_IP:8081/api/auth/register` ✅

### CI/CD (GitHub Actions)
- [ ] `.github/workflows/deploy.yml` created
- [ ] GitHub Secrets added (DOCKER_USERNAME, DOCKER_PASSWORD, EC2_HOST, EC2_SSH_KEY)
- [ ] Push to main branch → Actions tab shows pipeline running
- [ ] Pipeline completes successfully ✅
- [ ] New version auto-deployed to EC2 ✅

---

## Complete Flow Summary

```
MANUAL DEPLOY (no CI/CD):
─────────────────────────
Local machine:
  1. mvn clean package -DskipTests
  2. docker build -f Dockerfile.ec2 -t chiragrathi/student-app:latest .
  3. docker push chiragrathi/student-app:latest

EC2:
  4. ~/app/deploy.sh

Total: 4 steps, ~5 minutes

AUTOMATIC DEPLOY (with CI/CD):
───────────────────────────────
Local machine:
  1. git push origin main

GitHub Actions does everything automatically:
  2. mvn package
  3. docker build
  4. docker push → Docker Hub
  5. SSH → EC2 → deploy.sh

Total: 1 step! Zero manual work after git push! 🚀
```

---

## Registry Options (when you grow)

| Registry | Best for | Cost |
|---|---|---|
| Docker Hub | Learning, open source | Free (public) |
| AWS ECR | AWS-based projects | Pay per GB |
| GitHub GHCR | GitHub-based projects | Free (public) |
| Google GCR | GCP projects | Pay per GB |

```
Learning path:
  Now    → Docker Hub ✅ (you are here)
  Next   → GitHub Actions CI/CD
  Later  → AWS ECR (private, more secure)
  Pro    → Kubernetes + Helm charts
```

---

*Phase 5b Complete! Your deployment is now industry-standard!*
*git push → auto build → Docker Hub → EC2 → Live! 🚀*
