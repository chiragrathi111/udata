# Docker Multi-Stage Builds Guide 🏗️
## Day 03 - Optimized Production Images

---

## What is Multi-Stage Build? 🤔

**Multi-Stage Build** = Use multiple FROM statements in one Dockerfile

**Benefits:**
- Smaller final image
- Separate build and runtime
- More secure (no build tools in production)

---

## Why Use Multi-Stage? 💡

### Without Multi-Stage (Single Stage):
```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
CMD ["nginx"]

# Problems:
# ❌ Image size: 1.5GB (includes node, npm, build tools)
# ❌ Security risk (unnecessary tools in production)
# ❌ Slow deployment
```

### With Multi-Stage:
```dockerfile
# Stage 1: Build
FROM node:18 AS builder
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# Stage 2: Production
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html

# Benefits:
# ✅ Image size: 50MB (only nginx + built files)
# ✅ Secure (no build tools)
# ✅ Fast deployment
```

---

## Your Multi-Stage Dockerfile (Day 03) 📝

```dockerfile
# Stage 1: Build Stage (installer)
FROM node:18 AS installer

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy source code
COPY . .

# Build application
RUN npm run build

# Stage 2: Production Stage (developer)
FROM nginx:latest AS developer

# Copy built files from Stage 1
COPY --from=installer /app/build /usr/share/nginx/html
```

**What happens:**
1. Stage 1 builds the app (node:18 image)
2. Stage 2 copies only built files (nginx image)
3. Final image = nginx + built files only
4. node, npm, source code NOT in final image!

---

## Multi-Stage Build Patterns 🎯

### Pattern 1: Node.js + Nginx

```dockerfile
# Build stage
FROM node:18 AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Use case:** React, Vue, Angular apps

### Pattern 2: Go Application

```dockerfile
# Build stage
FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp

# Production stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder /app/myapp /myapp
CMD ["/myapp"]
```

**Result:** 
- Build image: 800MB
- Final image: 10MB!

### Pattern 3: Python Application

```dockerfile
# Build stage
FROM python:3.11 AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt
COPY . .

# Production stage
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY --from=builder /app .
ENV PATH=/root/.local/bin:$PATH
CMD ["python", "app.py"]
```

---

## Real-World Example: React App 🌍

### Project Structure:
```
day_03/
├── src/
│   ├── App.js
│   └── index.js
├── public/
│   └── index.html
├── package.json
└── Dockerfile
```

### Complete Dockerfile:
```dockerfile
# Stage 1: Build React app
FROM node:18-alpine AS build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build for production
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine AS production

# Copy built files from build stage
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom nginx config (optional)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

### Build & Run:
```bash
# Build multi-stage image
docker build -t react-app:multi-stage .

# Check image size
docker images react-app:multi-stage
# REPOSITORY   TAG           SIZE
# react-app    multi-stage   50MB  ✅

# Run container
docker run -dp 80:80 react-app:multi-stage

# Test
curl http://localhost
```

---

## Size Comparison 📊

### Single Stage:
```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install && npm run build
CMD ["nginx"]
```
**Image Size: 1.2GB** ❌

### Multi-Stage:
```dockerfile
FROM node:18 AS build
WORKDIR /app
COPY . .
RUN npm install && npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
```
**Image Size: 50MB** ✅

**Savings: 96% smaller!**

---

## Advanced Multi-Stage Techniques 🚀

### 1. Multiple Build Stages

```dockerfile
# Stage 1: Install dependencies
FROM node:18 AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm install

# Stage 2: Build application
FROM node:18 AS build
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY . .
RUN npm run build

# Stage 3: Production
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
```

### 2. Target Specific Stage

```bash
# Build only up to 'build' stage
docker build --target build -t myapp:build .

# Build full production image
docker build -t myapp:prod .
```

### 3. Development vs Production

```dockerfile
# Base stage
FROM node:18 AS base
WORKDIR /app
COPY package*.json ./

# Development stage
FROM base AS development
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]

# Build stage
FROM base AS build
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine AS production
COPY --from=build /app/build /usr/share/nginx/html
```

**Usage:**
```bash
# Development
docker build --target development -t myapp:dev .

# Production
docker build --target production -t myapp:prod .
```

---

## Best Practices 📚

### 1. Use Alpine Images
```dockerfile
# ✅ Good (small)
FROM node:18-alpine
FROM nginx:alpine

# ❌ Bad (large)
FROM node:18
FROM nginx:latest
```

### 2. Order Stages Efficiently
```dockerfile
# ✅ Good (cache-friendly)
COPY package*.json ./
RUN npm install
COPY . .

# ❌ Bad (cache breaks often)
COPY . .
RUN npm install
```

### 3. Name Your Stages
```dockerfile
# ✅ Good (readable)
FROM node:18 AS builder
FROM nginx:alpine AS production

# ❌ Bad (confusing)
FROM node:18
FROM nginx:alpine
```

### 4. Copy Only What's Needed
```dockerfile
# ✅ Good (minimal)
COPY --from=builder /app/build /usr/share/nginx/html

# ❌ Bad (unnecessary files)
COPY --from=builder /app /usr/share/nginx/html
```

---

## Commands 🔧

```bash
# Build multi-stage image
docker build -t myapp:multi .

# Build specific stage
docker build --target build -t myapp:build .

# Check image size
docker images myapp

# Compare sizes
docker images | grep myapp

# Build with build args
docker build --build-arg NODE_ENV=production -t myapp .

# Inspect image layers
docker history myapp:multi
```

---

## Troubleshooting 🔍

### Issue 1: COPY --from fails
```bash
# Error: invalid from flag value

# Solution: Check stage name
FROM node:18 AS builder  # Name here
COPY --from=builder      # Must match
```

### Issue 2: Files not found in final stage
```bash
# Check build output location
RUN npm run build
# Creates /app/build or /app/dist?

# Copy correct path
COPY --from=builder /app/build /usr/share/nginx/html
```

### Issue 3: Image still large
```bash
# Check what's in image
docker run --rm myapp:multi ls -la /

# Use alpine base images
FROM nginx:alpine  # Not nginx:latest
```

---

## Key Takeaways 🎯

1. **Multi-Stage** = Multiple FROM in one Dockerfile
2. **Smaller images** = 90%+ size reduction
3. **More secure** = No build tools in production
4. **Faster deployment** = Smaller images = faster push/pull
5. **Best practice** = Always use for production
6. **Stage naming** = Use AS to name stages
7. **COPY --from** = Copy between stages

---

**Multi-Stage Builds = Production-Ready Images! 🏗️**
