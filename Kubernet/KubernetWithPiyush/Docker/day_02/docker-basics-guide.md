# Docker Basics Complete Guide 🐳
## Day 02 - Building & Running Containers

---

## What is Docker? 🤔

**Docker** = Platform to build, ship, and run applications in containers

**Think of it like:**
- Shipping container for code
- Works same everywhere
- Isolated from host system

---

## Why Use Docker? 💡

### Without Docker:
```
Works on my machine ❌
Different environments = Different issues
Complex setup for each developer
```

### With Docker:
```
Works everywhere ✅
Same environment for all
One command to run
```

---

## Dockerfile Explained 📝

### Your Dockerfile (Day 02):

```dockerfile
FROM node:18
# Base image - Node.js version 18

WORKDIR /app
# Set working directory inside container

COPY package*.json ./
# Copy package files first (for caching)

RUN npm install --production
# Install dependencies (only production)

COPY . .
# Copy all application files

CMD ["node","src/index.js"]
# Command to run when container starts

EXPOSE 3000
# Document that app uses port 3000
```

---

## Building Docker Image 🏗️

```bash
# Build image
docker build -t day02:latest .

# Flags:
# -t = Tag (name) for image
# . = Use current directory (Dockerfile location)

# List images
docker images

# Output:
# REPOSITORY   TAG      IMAGE ID       CREATED         SIZE
# day02        latest   0196be1bc1a7   5 minutes ago   1.09GB
```

---

## Running Container 🚀

```bash
# Run container
docker run -dp 3000:3000 day02:latest

# Flags:
# -d = Detached mode (background)
# -p = Port mapping (host:container)
# 3000:3000 = Map port 3000 on host to port 3000 in container

# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop container
docker stop <container_id>

# Remove container
docker rm <container_id>

# Remove image
docker rmi day02:latest
```

---

## Docker Hub - Push & Pull 🌐

### Step 1: Create Docker Hub Account
```
Visit: https://hub.docker.com
Sign up for free account
```

### Step 2: Login
```bash
# Login to Docker Hub
docker login

# Enter username and password
# Or use browser authentication
```

### Step 3: Tag Image
```bash
# Tag image for Docker Hub
docker tag day02:latest chiragrat/testrepo:latest

# Format: docker tag <local-image> <username>/<repo>:<tag>

# Now you have two tags for same image:
# day02:latest
# chiragrat/testrepo:latest
```

### Step 4: Push to Docker Hub
```bash
# Push image
docker push chiragrat/testrepo:latest

# Image now available publicly!
```

### Step 5: Pull from Docker Hub
```bash
# Anyone can pull your image
docker pull chiragrat/testrepo:latest

# Run pulled image
docker run -dp 3000:3000 chiragrat/testrepo:latest
```

---

## Container Management 🔧

### Execute Commands in Container
```bash
# Enter container shell
docker exec -it <container_name> sh
# or
docker exec -it <container_name> bash

# Inside container:
ls -la
cat src/index.js
exit
```

### View Logs
```bash
# View container logs
docker logs <container_id>

# Follow logs (real-time)
docker logs -f <container_id>
```

### Inspect Container
```bash
# Get detailed info
docker inspect <container_id>

# Get specific info (IP address)
docker inspect -f '{{.NetworkSettings.IPAddress}}' <container_id>
```

---

## Real-World Example: Node.js App 🌍

### Project Structure:
```
day_02/
├── src/
│   └── index.js
├── package.json
└── Dockerfile
```

### package.json:
```json
{
  "name": "my-app",
  "version": "1.0.0",
  "main": "src/index.js",
  "dependencies": {
    "express": "^4.18.0"
  }
}
```

### src/index.js:
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello from Docker!');
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

### Build & Run:
```bash
# Build
docker build -t my-node-app .

# Run
docker run -dp 3000:3000 my-node-app

# Test
curl http://localhost:3000
# Output: Hello from Docker!
```

---

## Docker Commands Cheat Sheet 📋

```bash
# Images
docker images                    # List images
docker build -t name .          # Build image
docker rmi image_name           # Remove image
docker tag source target        # Tag image

# Containers
docker ps                       # List running containers
docker ps -a                    # List all containers
docker run -dp 3000:3000 image # Run container
docker stop container_id        # Stop container
docker start container_id       # Start container
docker rm container_id          # Remove container
docker logs container_id        # View logs
docker exec -it container sh    # Enter container

# Docker Hub
docker login                    # Login
docker push username/repo:tag   # Push image
docker pull username/repo:tag   # Pull image

# Cleanup
docker system prune             # Remove unused data
docker container prune          # Remove stopped containers
docker image prune              # Remove unused images
```

---

## Best Practices 📚

### 1. Use Specific Base Image Versions
```dockerfile
# ✅ Good
FROM node:18

# ❌ Bad
FROM node:latest
```

### 2. Copy package.json First (Layer Caching)
```dockerfile
# ✅ Good (dependencies cached)
COPY package*.json ./
RUN npm install
COPY . .

# ❌ Bad (rebuild deps every time)
COPY . .
RUN npm install
```

### 3. Use .dockerignore
```
# .dockerignore
node_modules
npm-debug.log
.git
.env
```

### 4. Use Production Dependencies
```dockerfile
RUN npm install --production
```

### 5. Don't Run as Root
```dockerfile
USER node
```

---

## Troubleshooting 🔍

### Issue 1: Port already in use
```bash
# Error: port 3000 already allocated

# Find process using port
lsof -i :3000

# Kill process
kill -9 <PID>

# Or use different port
docker run -dp 3001:3000 my-app
```

### Issue 2: Image build fails
```bash
# Check Dockerfile syntax
# Verify all files exist
# Check base image availability

# Build with no cache
docker build --no-cache -t my-app .
```

### Issue 3: Container exits immediately
```bash
# Check logs
docker logs <container_id>

# Common causes:
# - Application crashes
# - Wrong CMD
# - Missing dependencies
```

---

## Key Takeaways 🎯

1. **Dockerfile** = Instructions to build image
2. **Image** = Template for containers
3. **Container** = Running instance of image
4. **docker build** = Create image
5. **docker run** = Start container
6. **Docker Hub** = Share images
7. **Port mapping** = Access container from host

---

**Docker = Package Once, Run Anywhere! 🐳**
