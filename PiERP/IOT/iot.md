# AWS EC2 Deployment Guide for IoT-Sync

This guide explains how to deploy the **IoT-Sync** application on an **AWS EC2 Ubuntu Server** using **Docker Compose**.

---

# Prerequisites

- AWS Account
- EC2 Ubuntu 22.04 Instance
- SSH Access
- Docker knowledge (basic)

---

# Step 1: Provision AWS EC2 Instance

## Launch an Instance

Navigate to:

> AWS Console → EC2 → Launch Instance


### AMI
```text
Ubuntu Server 22.04 LTS (64-bit)
```

### Instance Type

Recommended:

```text
t3.small
```

Preferred:

```text
t3.medium
```

---

## Security Group Rules

| Type | Port | Source |
|------|------|--------|
| SSH | 22 | Your IP |
| HTTP | 80 | 0.0.0.0/0 |
| HTTPS | 443 | 0.0.0.0/0 |

---

# Step 2: Install Docker and Docker Compose

SSH into the server.

Update packages:

```bash
sudo apt-get update -y
```

Install dependencies:

```bash
sudo apt-get install -y \
ca-certificates \
curl \
gnupg \
lsb-release
```

Create keyring directory:

```bash
sudo mkdir -p /etc/apt/keyrings
```

Download Docker GPG key:

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor \
-o /etc/apt/keyrings/docker.gpg
```

Add Docker repository:

```bash
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Update repositories:

```bash
sudo apt-get update -y
```

Install Docker:

```bash
sudo apt-get install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin
```

Enable Docker:

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

Add current user to Docker group:

```bash
sudo usermod -aG docker $USER
```

Logout and reconnect to SSH.

Verify installation:

```bash
docker --version

docker compose version
```

---

# Step 3: Clone Repository

```bash
git clone <repository-url> iot-sync

cd iot-sync
```

---

# Step 4: Configure Environment Variables

Create a `.env` file.

```bash
nano .env
```

Example configuration:

```env
POSTGRES_DB=iot_sync

POSTGRES_USER=iot_prod_admin

POSTGRES_PASSWORD=ReplaceWithAStrongPassword


JWT_SECRET=ReplaceWith32CharacterSecret
```

---

# Step 5: Configure Production Ports

Open docker-compose.yml

```bash
nano docker-compose.yml
```

Find:

```yaml
ports:
  - "3000:80"
```

Change to:

```yaml
ports:
  - "80:80"
```

Save the file.

---

# Step 6: Start Application

Make scripts executable.

```bash
chmod +x *.sh
```

Run deployment script.

```bash
./start-docker-full.sh
```

This script will:

- Stop existing containers
- Build images
- Start services
- Wait for health checks

---

# Step 7: Verify Deployment


## Running Containers

```bash
docker compose ps
```

---

## View Logs

```bash
docker compose logs -f
```

---

## Database Logs

```bash
docker compose logs -f db
```

---

## Backend Logs

```bash
docker compose logs -f app
```

---

## Frontend Logs

```bash
docker compose logs -f frontend
```

---

## Stop Services

```bash
docker compose down
```

---

# Alternative Deployment Method

## Deploy Without Source Code

Recommended for production environments.


Advantages

- Faster deployments
- Lower CPU usage
- No source code stored on server
- Better security


---

# Build Images Locally

Login to Docker Hub.

```bash
docker login
```

Build backend image.

```bash
docker build \
-t your-docker-username/iot-sync-backend:latest \
./backend
```

Push image.

```bash
docker push your-docker-username/iot-sync-backend:latest
```


Build frontend image.

```bash
docker build \
-t your-docker-username/iot-sync-frontend:latest \
./frontend
```

Push image.

```bash
docker push your-docker-username/iot-sync-frontend:latest
```


---

# Deploy on EC2


Create deployment directory.

```bash
mkdir iot-sync-deploy

cd iot-sync-deploy
```


Create compose file.

```bash
nano docker-compose.yml
```


Create environment file.

```bash
nano .env
```


Add variables.

```env
POSTGRES_DB=iot_sync

POSTGRES_USER=iot_prod_admin

POSTGRES_PASSWORD=StrongPassword


JWT_SECRET=VeryLongSecretKey
```


Start services.

```bash
docker compose up -d
```


Check status.

```bash
docker compose ps
```


View logs.

```bash
docker compose logs -f
```


Stop services.

```bash
docker compose down
```


---

# Useful Docker Commands

```bash
docker ps


docker images


docker stats


docker compose ps


docker compose logs -f


docker compose restart


docker compose down


docker compose up -d
```

---

# Deployment Completed

The application should now be accessible using:

```text
http://<EC2-Public-IP>

or

https://<your-domain>
```
