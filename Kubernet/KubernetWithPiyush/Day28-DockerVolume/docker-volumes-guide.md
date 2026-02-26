# Docker Volumes Complete Guide 💾
## Container Data Persistence

---

## What are Docker Volumes? 🤔

**Docker Volumes** = Persistent storage for containers

**Problem:**
```
Container created → Data written → Container deleted → Data lost ❌
```

**Solution:**
```
Container created → Data written to volume → Container deleted → Data persists ✅
```

---

## Why Use Volumes? 💡

### Without Volumes:
```
Database container → Stores data → Restart → Data gone ❌
```

### With Volumes:
```
Database container → Stores data in volume → Restart → Data still there ✅
```

---

## Volume Types 📊

### 1. Named Volumes (Recommended)
```bash
docker volume create mydata
docker run -v mydata:/data nginx
```

### 2. Bind Mounts
```bash
docker run -v /host/path:/container/path nginx
```

### 3. tmpfs (Memory)
```bash
docker run --tmpfs /tmp nginx
```

---

## Creating Volumes 🛠️

```bash
# Create volume
docker volume create myvolume

# List volumes
docker volume ls

# Inspect volume
docker volume inspect myvolume

# Remove volume
docker volume rm myvolume

# Remove unused volumes
docker volume prune
```

---

## Using Volumes 📝

### Example 1: MySQL Database

```bash
# Create volume
docker volume create mysql-data

# Run MySQL with volume
docker run -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=password \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0

# Data persists even after container deletion
docker rm -f mysql
docker run -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=password \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0
# Data still there! ✅
```

### Example 2: Nginx with Config

```bash
# Create volume
docker volume create nginx-config

# Run nginx
docker run -d \
  --name nginx \
  -v nginx-config:/etc/nginx \
  -p 80:80 \
  nginx

# Copy config to volume
docker cp nginx.conf nginx:/etc/nginx/nginx.conf

# Restart nginx
docker restart nginx
```

---

## Bind Mounts 📁

```bash
# Mount host directory
docker run -d \
  --name webapp \
  -v /home/user/app:/usr/share/nginx/html \
  -p 80:80 \
  nginx

# Changes on host reflect in container immediately
echo "Hello" > /home/user/app/index.html
curl localhost
# Output: Hello
```

---

## Docker Compose with Volumes 🐳

```yaml
version: '3.8'
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: password
    volumes:
      - mysql-data:/var/lib/mysql
  
  webapp:
    image: nginx
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html
      - nginx-config:/etc/nginx

volumes:
  mysql-data:
  nginx-config:
```

---

## Volume Drivers 🚗

### Local (Default)
```bash
docker volume create --driver local myvolume
```

### NFS
```bash
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.1,rw \
  --opt device=:/path/to/dir \
  nfs-volume
```

---

## Best Practices 📚

### 1. Use Named Volumes
```bash
# ✅ Good
docker volume create mydata
docker run -v mydata:/data nginx

# ❌ Bad (anonymous volume)
docker run -v /data nginx
```

### 2. Backup Volumes
```bash
# Backup volume
docker run --rm \
  -v mydata:/data \
  -v $(pwd):/backup \
  busybox tar czf /backup/backup.tar.gz /data

# Restore volume
docker run --rm \
  -v mydata:/data \
  -v $(pwd):/backup \
  busybox tar xzf /backup/backup.tar.gz -C /
```

### 3. Clean Up Unused Volumes
```bash
docker volume prune
```

---

## Key Takeaways 🎯

1. **Volumes** = Persistent storage
2. **Named volumes** = Recommended
3. **Bind mounts** = Development
4. **Backup** = Important for data
5. **Clean up** = Remove unused volumes

**Docker Volumes = Data Persistence! 💾**
