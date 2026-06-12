# Phase 4 — Docker Guide
## Containerize Spring Boot App + PostgreSQL

---

## Table of Contents
1. [What is Docker](#1-what-is-docker)
2. [Install Docker](#2-install-docker)
3. [Files to Create](#3-files-to-create)
4. [Dockerfile](#4-dockerfile)
5. [docker-compose.yml](#5-docker-composeyml)
6. [application-docker.properties](#6-application-dockerproperties)
7. [Build and Run](#7-build-and-run)
8. [Docker Commands Daily Use](#8-docker-commands-daily-use)
9. [Common Errors and Fixes](#9-common-errors-and-fixes)
10. [How Everything Connects](#10-how-everything-connects)
11. [Quick Checklist](#11-quick-checklist)

---

## 1. What is Docker

### Hindi mein
```
Socho tumhara app ek dabba (container) mein band hai.
Is dabbe mein hai: Java app + PostgreSQL + saari settings.
Yeh dabba kisi bhi machine pe same tarah chalta hai!

Without Docker — "works on my machine" problem:
  Dev laptop:    Java 17, PostgreSQL 15 → works ✅
  Friend laptop: Java 11, PostgreSQL 13 → fails ❌
  AWS server:    different OS           → fails ❌

With Docker — runs same everywhere:
  Docker container: Java 17 + PostgreSQL 15 + your app
  Dev laptop   → docker compose up → works ✅
  Friend       → docker compose up → works ✅
  AWS server   → docker compose up → works ✅
```

### 4 Core Concepts
```
1. Dockerfile     = recipe to build your app image
                    (FROM, COPY, RUN, ENTRYPOINT)

2. Image          = built package — like a ZIP of your app
                    (docker build → creates image)

3. Container      = running instance of image
                    (docker run → creates container from image)

4. docker-compose = run multiple containers together
                    (your app + PostgreSQL started with one command)
```

### Your project structure in Docker
```
docker compose up
      ↓
┌─────────────────────────────────────┐
│  Container 1: student-app           │
│  Java 17 + Spring Boot              │
│  Port: 8081                         │
│  Reads DB_URL from environment      │
└──────────────┬──────────────────────┘
               │ connects to
┌──────────────▼──────────────────────┐
│  Container 2: postgres-db           │
│  PostgreSQL 15                      │
│  Port: 5432 (internal)              │
│  Port: 5433 (your machine)          │
│  Data stored in volume (persists!)  │
└─────────────────────────────────────┘
```

---

## 2. Install Docker

```bash
# Ubuntu/Linux
sudo apt-get update
sudo apt-get install docker.io docker-compose-plugin -y
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (no sudo needed for docker commands)
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version
docker compose version
```

### Fix DNS issue (IMPORTANT — do this right after install)
If Docker can't pull images, it's a DNS problem. Fix it immediately:
```bash
# Create Docker daemon config
sudo mkdir -p /etc/docker
sudo nano /etc/docker/daemon.json
```

Add this content:
```json
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
```

```bash
# Restart Docker to apply DNS fix
sudo systemctl restart docker

# Test it works
docker pull hello-world
# Expected: Successfully pulled hello-world ✅
```

---

## 3. Files to Create

```
Student/                              ← project root
├── Dockerfile                        ← NEW: how to build app image
├── docker-compose.yml                ← NEW: run app + postgres together
├── .dockerignore                     ← NEW: what NOT to copy into image
├── .env                              ← already exists
├── pom.xml                           ← no change
└── src/
    └── main/
        └── resources/
            ├── application.properties          ← local dev (unchanged)
            └── application-docker.properties   ← NEW: used inside Docker
```

---

## 4. Dockerfile

Create at project root (same level as pom.xml):

```dockerfile
# ── Stage 1: Build the JAR ───────────────────────────────
# Use Maven + Java 17 to build the project
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Set working directory inside container
WORKDIR /app

# Copy pom.xml first — Docker caches this layer
# If pom.xml doesn't change → Maven deps not re-downloaded!
COPY pom.xml .

# Download all dependencies (cached if pom.xml unchanged)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the JAR (skip tests — we run them separately)
RUN mvn clean package -DskipTests


# ── Stage 2: Run the JAR ─────────────────────────────────
# Use lightweight JRE (not full JDK) — smaller image!
FROM eclipse-temurin:17-jre-alpine

# Set working directory
WORKDIR /app

# Copy ONLY the built JAR from Stage 1
# This keeps the final image small (no Maven, no source code)
COPY --from=builder /app/target/*.jar app.jar

# Expose port 8081
EXPOSE 8081

# Run the app with docker profile
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=docker"]
```

### Why 2 stages?
```
Stage 1 (builder): Maven + full JDK = ~600MB
Stage 2 (runtime): JRE only         = ~180MB
Final image is much smaller and faster to deploy!
```

---

## 5. docker-compose.yml

Create at project root:

```yaml
# NOTE: Do NOT add "version:" line — it is obsolete in newer Docker
# Adding version causes: "the attribute version is obsolete" warning

services:

  # ── Service 1: PostgreSQL Database ───────────────────────
  postgres-db:
    image: postgres:15-alpine
    container_name: student-postgres
    restart: unless-stopped

    environment:
      POSTGRES_DB: studentdb
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres

    ports:
      - "5433:5432"
      # 5433 on your machine → 5432 inside container
      # Using 5433 to avoid conflict with local PostgreSQL!

    volumes:
      - postgres_data:/var/lib/postgresql/data
      # Named volume — data survives container restart

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
      # App won't start until DB is healthy


  # ── Service 2: Spring Boot App ────────────────────────────
  student-app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: student-app
    restart: unless-stopped

    ports:
      - "8081:8081"

    environment:
      # "postgres-db" = Docker service name above
      # Docker automatically resolves it to container IP!
      DB_URL: jdbc:postgresql://postgres-db:5432/studentdb
      DB_USERNAME: postgres
      DB_PASSWORD: postgres
      JWT_SECRET: mySecretKey12345678901234567890AB
      JWT_EXPIRATION: 86400000

    depends_on:
      postgres-db:
        condition: service_healthy
        # Waits for postgres healthcheck to pass before starting app


# ── Volumes ───────────────────────────────────────────────
volumes:
  postgres_data:
  # Data persists even after: docker compose down
  # Only deleted with: docker compose down -v
```

### Key things to remember
```
1. NO "version:" line — causes warning, remove it
2. Use "postgres-db" (service name) as DB hostname — NOT localhost!
3. Port 5433:5432 — avoids conflict with local PostgreSQL
4. depends_on with healthcheck — app waits for DB to be ready
5. Named volume — data survives restarts
```

---

## 6. application-docker.properties

Create at `src/main/resources/application-docker.properties`:

```properties
# application-docker.properties
# Used when: --spring.profiles.active=docker (set in Dockerfile ENTRYPOINT)

spring.application.name=Student
server.port=8081

# Database — values injected by docker-compose environment section
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false

# JWT — values injected by docker-compose
jwt.secret=${JWT_SECRET}
jwt.expiration=${JWT_EXPIRATION}

# Swagger
springdoc.api-docs.enabled=true
springdoc.swagger-ui.enabled=true
springdoc.swagger-ui.path=/swagger-ui.html

# Logging
logging.level.org.example.student=INFO
logging.level.org.springframework=WARN
```

### CRITICAL RULE for .properties files
```properties
# ✅ CORRECT — comment on its OWN line
# This is a comment explaining the value
spring.jpa.show-sql=false

# ❌ WRONG — comment on SAME line as value — BREAKS the app!
spring.jpa.show-sql=false    # this is a comment  ← DO NOT DO THIS

# Why? Spring reads EVERYTHING after = as the value
# It tries to convert "false    # this is a comment" to boolean → FAILS!
```

---

## 7. Build and Run

### Step by step — first time
```bash
# Step 1: Go to project root
cd ~/Documents/Rathi/Student

# Step 2: Build JAR using Maven wrapper
# Make sure JAVA_HOME points to Java 17
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 ./mvnw clean package -DskipTests

# OR build from IntelliJ:
# Maven panel (right side) → Lifecycle → package

# Step 3: Verify JAR was created
ls target/*.jar
# Should show: target/Student-0.0.1-SNAPSHOT.jar

# Step 4: Build Docker image and start containers
docker compose up --build

# --build = rebuild image even if it exists
# First time: 3-5 minutes (downloading base images)
# Next time: much faster (layers cached)
```

### Run in background (recommended)
```bash
docker compose up --build -d
# -d = detached mode, runs in background

# Check status
docker compose ps

# Expected output:
# NAME               STATUS          PORTS
# student-app        Up              0.0.0.0:8081->8081/tcp
# student-postgres   Up (healthy)    0.0.0.0:5433->5432/tcp
```

### Verify app is working
```bash
# Test API
curl -X POST http://localhost:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123","role":"ADMIN"}'

# Open Swagger in browser
http://localhost:8081/swagger-ui/index.html
```

---

## 8. Docker Commands Daily Use

### Start / Stop
```bash
docker compose up --build -d    # build + start in background
docker compose up -d            # start without rebuild
docker compose down             # stop + remove containers
docker compose down -v          # stop + remove containers + DELETE volume data
docker compose restart          # restart all containers
docker compose restart student-app  # restart only app container
```

### Logs
```bash
docker compose logs             # all logs
docker compose logs student-app # only app logs
docker compose logs postgres-db # only DB logs
docker compose logs -f          # follow logs (live, like tail -f)
docker compose logs -f student-app  # follow only app logs
```

### Status and Info
```bash
docker compose ps               # show running containers
docker ps                       # all running containers on system
docker images                   # all built images
docker volume ls                # all volumes
```

### Debug — go inside container
```bash
docker exec -it student-app sh         # enter app container shell
docker exec -it student-postgres sh    # enter DB container shell

# Inside postgres container — connect to DB
psql -U postgres -d studentdb
\dt                             # show all tables
SELECT * FROM students;         # query data
\q                              # quit
```

### Cleanup
```bash
docker compose down             # stop containers
docker image rm student-student-app    # remove app image
docker system prune             # remove ALL unused images/containers
docker system prune -a          # remove everything (careful!)
```

### Rebuild after code change
```bash
# After changing Java code:
docker compose down
./mvnw clean package -DskipTests
docker compose up --build -d
```

---

## 9. Common Errors and Fixes

### Error 1: "version is obsolete" warning
```
WARN: the attribute `version` is obsolete

Cause: Old docker-compose.yml has "version: '3.8'" at top
Fix:   Remove the version line completely from docker-compose.yml
```

### Error 2: DNS / Cannot pull images
```
Error: dial tcp: lookup auth.docker.io: server misbehaving
Error: failed to fetch anonymous token

Cause: Docker can't resolve DNS to reach Docker Hub
Fix:
  sudo nano /etc/docker/daemon.json
  Add: {"dns": ["8.8.8.8", "8.8.4.4"]}
  sudo systemctl restart docker
  docker pull hello-world  ← test it works
```

### Error 3: Failed to bind properties (comment on same line)
```
Error: Failed to bind properties under 'spring.jpa.show-sql' to boolean
Value: "false              # false in docker — cleaner logs"

Cause: Comment on same line as property value
Fix:   Remove inline comments from .properties files

WRONG: spring.jpa.show-sql=false   # comment here
RIGHT:
  # comment on its own line
  spring.jpa.show-sql=false
```

### Error 4: App starts before DB is ready
```
Error: Connection refused to postgres-db:5432

Cause: App container starts before PostgreSQL is ready
Fix:   Already handled in docker-compose.yml with:
  depends_on:
    postgres-db:
      condition: service_healthy
  And healthcheck on postgres-db service
```

### Error 5: Port already in use
```
Error: Bind for 0.0.0.0:8081 failed: port is already allocated

Cause: Something else running on port 8081
Fix:
  sudo fuser -k 8081/tcp   ← kill process on port
  docker compose up -d
```

### Error 6: Port 5432 conflict with local PostgreSQL
```
Error: Bind for 0.0.0.0:5432 failed

Cause: Local PostgreSQL using port 5432
Fix:   Already handled — we use 5433:5432 in docker-compose.yml
  5433 = your machine port
  5432 = inside container port
```

### Error 7: Changes not showing after rebuild
```
Cause: Docker using old cached image

Fix:
  docker compose down
  docker compose up --build    ← --build forces rebuild
```

### Error 8: No space left on device
```
Error: no space left on device

Cause: Too many old Docker images/containers

Fix:
  docker system prune          ← removes unused images
  docker system prune -a       ← removes everything unused
```

### Error 9: buildx not installed warning
```
WARN: Docker Compose is configured to build using Bake, but buildx isn't installed

Cause: Newer Docker Compose expects buildx plugin
Fix:   This is just a warning, not an error — app still builds
  OR install buildx:
  sudo apt-get install docker-buildx-plugin
```

### Error 10: Cannot connect to docker daemon
```
Error: Cannot connect to the Docker daemon at unix:///var/run/docker.sock

Cause: Docker service not running
Fix:
  sudo systemctl start docker
  sudo systemctl enable docker  ← auto-start on boot
```

---

## 10. How Everything Connects

### Environment variable flow
```
docker-compose.yml
  environment:
    DB_URL: jdbc:postgresql://postgres-db:5432/studentdb
    DB_USERNAME: postgres
    DB_PASSWORD: postgres
         ↓
Docker injects into container as OS environment variables
         ↓
StudentCrudApplication.java
  loadEnvFile() → .env not found → IOException → skip (OK!)
  System.getenv("DB_URL") → has value from Docker ✅
         ↓
application-docker.properties
  spring.datasource.url=${DB_URL} → resolved to actual URL ✅
         ↓
Spring Boot connects to PostgreSQL inside Docker ✅
```

### Profile selection
```
Dockerfile ENTRYPOINT:
  java -jar app.jar --spring.profiles.active=docker
                                              ↑
                                    loads application-docker.properties

Local dev (no Docker):
  mvn spring-boot:run → loads application.properties

AWS production (later):
  java -jar app.jar --spring.profiles.active=prod
                                          → loads application-prod.properties
```

### Which properties file loads when
| Where | Command | Properties file |
|---|---|---|
| Local dev | `mvn spring-boot:run` | `application.properties` + `.env` |
| Docker | `docker compose up` | `application-docker.properties` |
| AWS prod | `java -jar --spring.profiles.active=prod` | `application-prod.properties` |

### How "postgres-db" hostname works
```
docker-compose.yml defines two services:
  postgres-db    ← service name = hostname inside Docker network
  student-app    ← this service

When student-app connects to:
  jdbc:postgresql://postgres-db:5432/studentdb
                   ↑
  Docker resolves "postgres-db" to the container's IP automatically!
  You CANNOT use "localhost" here — that would mean the app container itself
```

### Data persistence
```
docker compose down      → containers deleted, DATA SURVIVES (volume)
docker compose up        → containers recreated, data still there ✅

docker compose down -v   → containers deleted, VOLUME DELETED, data gone ❌
Use -v only when you want to start completely fresh!
```

---

## 11. Quick Checklist

### Setup
- [ ] Docker installed (`docker --version`)
- [ ] DNS fixed (`/etc/docker/daemon.json` with Google DNS)
- [ ] Docker restarted after DNS fix
- [ ] `docker pull hello-world` works ✅

### Files created
- [ ] `Dockerfile` at project root
- [ ] `docker-compose.yml` at project root (NO version line!)
- [ ] `.dockerignore` at project root
- [ ] `application-docker.properties` in `src/main/resources/`

### Properties file rules
- [ ] NO inline comments (comment on same line as value)
- [ ] All comments on their own lines
- [ ] `spring.jpa.show-sql=false` (just false, no comment after)

### Running
- [ ] JAR built: `./mvnw clean package -DskipTests`
- [ ] JAR exists: `ls target/*.jar`
- [ ] `docker compose up --build` runs without error
- [ ] Both containers show `Up` in `docker compose ps`
- [ ] API works: `curl http://localhost:8081/api/auth/register`
- [ ] Swagger works: `http://localhost:8081/swagger-ui/index.html`

---

## Dockerfile explained line by line

```dockerfile
# Which base image to use — Maven 3.9.6 with Java 17 (for building)
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Working directory inside container
WORKDIR /app

# Copy pom.xml first (caching trick)
# If pom.xml unchanged → Docker uses cached layer → faster builds!
COPY pom.xml .

# Download dependencies (cached if pom.xml unchanged)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build JAR without running tests
RUN mvn clean package -DskipTests

# ── New stage — smaller final image ──
# Just JRE (not JDK) — no compiler needed to RUN the app
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy only the JAR from builder stage
# Everything else (Maven, source code) is left behind!
COPY --from=builder /app/target/*.jar app.jar

# Document which port the app uses
EXPOSE 8081

# Command to run when container starts
# --spring.profiles.active=docker → loads application-docker.properties
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=docker"]
```

---

## Java version — system vs Docker

```
Problem: Other projects use Java 11, this project needs Java 17

Solution: System Java = 11 (unchanged), Docker has its own Java 17!

System terminal:  java -version → 11 ✅ (other projects safe)
IntelliJ project: SDK → Java 17 ✅ (project level setting)
Docker container: FROM eclipse-temurin:17 → Java 17 ✅

Docker downloads its own Java 17 inside the container.
Your system Java 11 is completely ignored by Docker!
```

### Build JAR with Java 17 without changing system Java
```bash
# Option A: Use IntelliJ Maven panel
# Right side → Maven → Lifecycle → package (double click)

# Option B: Use terminal with specific JAVA_HOME
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 ./mvnw clean package -DskipTests
```

---

*Phase 4 Complete! Next: Phase 5 — AWS EC2 + RDS + Parameter Store*
*Your app now runs in Docker — same on any machine! 🐳*
