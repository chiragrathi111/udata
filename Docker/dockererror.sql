Docker can't connect to internet (DNS issue)

This is a DNS resolution problem on your Linux machine. Docker can't reach Docker Hub to download images.

# Step 1 — Create Docker DNS config
sudo mkdir -p /etc/docker
sudo nano /etc/docker/daemon.json

{
  "dns": ["8.8.8.8", "8.8.4.4"]
}

# Step 2 — Restart Docker
sudo systemctl restart docker

# Step 3 — Test if Docker can now reach internet
docker pull hello-world

# Expected: Successfully pulled hello-world ✅

Also fix docker-compose.yml — remove version + fix warning


--------------------------------------------------------------------------------
After DNS fix — run in this order

# 1. Test internet works
docker pull hello-world

# 2. Then build your project
docker compose up --build

=================================================================================
1. DNS fix first → /etc/docker/daemon.json → 8.8.8.8

2. NO version: line in docker-compose.yml

3. NO inline comments in .properties files
   Wrong: spring.jpa.show-sql=false  # comment
   Right: put comment on its own line

4. Use service name as hostname
   DB_URL=jdbc:postgresql://postgres-db:5432/db
                             ↑ service name, NOT localhost

5. Docker has its own Java — system Java version doesn't matter