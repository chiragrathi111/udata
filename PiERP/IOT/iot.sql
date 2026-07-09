version: '3.9'

services:
  db:
    image: timescale/timescaledb:latest-pg15
    container_name: iot-sync-db
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-iot_sync}
      POSTGRES_USER: ${POSTGRES_USER:-iot_sync}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-iot_sync_pwd}
    volumes:
      - iot_sync_db_data:/var/lib/postgresql/data
    ports:
      - "5433:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER:-iot_sync} -d $${POSTGRES_DB:-iot_sync}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - iot_sync_net

  app:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: iot-sync-app
    depends_on:
      db:
        condition: service_healthy
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://db:5432/${POSTGRES_DB:-iot_sync}
      SPRING_DATASOURCE_USERNAME: ${POSTGRES_USER:-iot_sync}
      SPRING_DATASOURCE_PASSWORD: ${POSTGRES_PASSWORD:-iot_sync_pwd}
      JWT_SECRET: ${JWT_SECRET:-change-me-in-production-must-be-at-least-32-characters-long}
    ports:
      - "8080:8080"
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8080/api/health || exit 1"]
      interval: 15s
      timeout: 5s
      retries: 8
      start_period: 60s
    networks:
      - iot_sync_net

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: iot-sync-frontend
    ports:
      - "3000:80"
    depends_on:
      app:
        condition: service_healthy
    networks:
      - iot_sync_net

volumes:
  iot_sync_db_data:

networks:
  iot_sync_net:
    driver: bridge
==========================================================
package com.pipra.iotsync.controller;

import com.pipra.iotsync.model.CatalogFieldSchema;
import com.pipra.iotsync.model.CatalogSensorType;
import com.pipra.iotsync.service.CatalogService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/catalog")
@RequiredArgsConstructor
public class CatalogController {

    private final CatalogService catalogService;

    @GetMapping("/sensor-types")
    public ResponseEntity<List<CatalogSensorType>> listSensorTypes() {
        return ResponseEntity.ok(catalogService.listSensorTypes());
    }

    @GetMapping("/sensor-types/{id}")
    public ResponseEntity<Map<String, Object>> getSensorType(@PathVariable Long id) {
        return ResponseEntity.ok(catalogService.getSensorTypeWithFields(id));
    }

    @PostMapping("/sensor-types")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<CatalogSensorType> createSensorType(@RequestBody CatalogSensorType type) {
        return ResponseEntity.ok(catalogService.createSensorType(type));
    }

    @PutMapping("/sensor-types/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<CatalogSensorType> updateSensorType(@PathVariable Long id,
                                                               @RequestBody CatalogSensorType updates) {
        return ResponseEntity.ok(catalogService.updateSensorType(id, updates));
    }

    @GetMapping("/sensor-types/{id}/fields")
    public ResponseEntity<List<CatalogFieldSchema>> getFields(@PathVariable Long id) {
        return ResponseEntity.ok(catalogService.getFieldsForType(id));
    }

    @PostMapping("/sensor-types/{id}/fields/import")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<CatalogFieldSchema>> importFields(@PathVariable Long id,
                                                                  @RequestParam("file") MultipartFile file) {
        return ResponseEntity.ok(catalogService.importFieldsFromCsv(id, file));
    }

    @PostMapping("/sensor-types/{id}/fields")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<CatalogFieldSchema> addField(@PathVariable Long id,
                                                        @RequestBody CatalogFieldSchema field) {
        return ResponseEntity.ok(catalogService.addField(id, field));
    }

    @PutMapping("/fields/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<CatalogFieldSchema> updateField(@PathVariable Long id,
                                                           @RequestBody CatalogFieldSchema updates) {
        return ResponseEntity.ok(catalogService.updateField(id, updates));
    }

    @DeleteMapping("/fields/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, String>> deactivateField(@PathVariable Long id) {
        catalogService.deactivateField(id);
        return ResponseEntity.ok(Map.of("status", "ok"));
    }
}
========================================================================
#!/usr/bin/env bash

# IoT-Sync — Start Local App + Frontend Only
# Starts Spring Boot (Maven) and the Vite dev server from local source.

# Exit on errors
set -e

# Get script directory
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BE_DIR="$ROOT/backend"
FE_DIR="$ROOT/frontend"
PID_FILE="$ROOT/.dev-pids"
LOGS_DIR="$ROOT/logs"

echo -e "\e[36m==========================================\e[0m"
echo -e "\e[36m  IoT-Sync — Local App + Frontend\e[0m"
echo -e "\e[90m  Spring Boot + Vite (no Docker changes)\e[0m"
echo -e "\e[36m==========================================\e[0m"
echo ""

mkdir -p "$LOGS_DIR"

# Load .env.local (JDK / Maven / Node paths)
ENV_LOCAL="$ROOT/.env.local"
if [ -f "$ENV_LOCAL" ]; then
    echo -e "\e[90mLoading paths from .env.local...\e[0m"
    # Export variables from .env.local
    while IFS= read -r line || [ -n "$line" ]; do
        # Ignore comments and empty lines
        if [[ ! "$line" =~ ^# ]] && [[ "$line" =~ = ]]; then
            key=$(echo "$line" | cut -d'=' -f1 | tr -d '[:space:]')
            value=$(echo "$line" | cut -d'=' -f2- | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
            if [ -n "$key" ] && [ -n "$value" ]; then
                export "$key"="$value"
            fi
        fi
    done < "$ENV_LOCAL"

    if [ -n "$JDK_HOME" ] && [ -d "$JDK_HOME" ]; then
        export JAVA_HOME="$JDK_HOME"
        export PATH="$JDK_HOME/bin:$PATH"
        echo -e "\e[90m  JDK:   $JDK_HOME\e[0m"
    fi
    if [ -n "$MAVEN_HOME" ] && [ -d "$MAVEN_HOME" ]; then
        export PATH="$MAVEN_HOME/bin:$PATH"
        echo -e "\e[90m  Maven: $MAVEN_HOME\e[0m"
    fi
    if [ -n "$NODE_HOME" ] && [ -d "$NODE_HOME" ]; then
        export PATH="$NODE_HOME/bin:$NODE_HOME:$PATH"
        echo -e "\e[90m  Node:  $NODE_HOME\e[0m"
    fi
else
    echo -e "\e[90m(No .env.local — using system PATH for JDK/Maven/Node)\e[0m"
fi
echo ""

# Pre-flight checks
if ! command -v mvn &> /dev/null; then
    echo -e "\e[31m[ERROR] 'mvn' not found. Please install Maven or add to system PATH / .env.local.\e[0m"
    exit 1
fi
if ! command -v node &> /dev/null; then
    echo -e "\e[31m[ERROR] 'node' not found. Please install Node.js or add to system PATH / .env.local.\e[0m"
    exit 1
fi

# Warn if DB appears unreachable
echo -e "\e[90mChecking DB connectivity...\e[0m"
if nc -z -w3 localhost 5433 2>/dev/null; then
    echo -e "\e[32m  TimescaleDB reachable on localhost:5433.\e[0m"
else
    echo -e "\e[33m  [WARN] Nothing listening on localhost:5433.\e[0m"
    echo -e "\e[33m         Start the DB first: docker compose up -d db\e[0m"
    echo -e "\e[90m         Continuing anyway — Spring Boot will retry on startup.\e[0m"
fi

# Stop any existing dev processes
echo ""
echo -e "\e[90mStopping any existing app processes...\e[0m"
if [ -f "$PID_FILE" ]; then
    while read -r pid; do
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            # kill process group/tree
            kill -9 -"$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null || true
            echo -e "\e[90m  Stopped PID $pid.\e[0m"
        fi
    done < "$PID_FILE"
    rm -f "$PID_FILE"
fi

for port in 8080 5173; do
    PIDS=$(lsof -t -i:$port -sTCP:LISTEN 2>/dev/null || true)
    if [ -n "$PIDS" ]; then
        for pid in $PIDS; do
            kill -9 "$pid" 2>/dev/null || true
        done
        echo -e "\e[90m  Cleared port $port.\e[0m"
    fi
done

# Clean build
echo ""
echo -e "\e[36mRunning mvn clean verify...\e[0m"
BUILD_LOG="$LOGS_DIR/build-$(date +%Y%m%d_%H%M%S).log"
(cd "$BE_DIR" && mvn clean verify) 2>&1 | tee "$BUILD_LOG"
BUILD_STATUS=${PIPESTATUS[0]}
set +e
set -e

if [ $BUILD_STATUS -ne 0 ]; then
    echo ""
    echo -e "\e[31m[ERROR] Build failed. Fix compilation errors before starting.\e[0m"
    echo -e "\e[90m        Full log: $BUILD_LOG\e[0m"
    exit 1
fi
echo -e "\e[32m  Build successful.\e[0m"

# Start Spring Boot backend
echo ""
echo -e "\e[36mStarting Spring Boot backend...\e[0m"
BE_LOG="$LOGS_DIR/backend-$(date +%Y%m%d_%H%M%S).log"

# Run in background and save pid
(cd "$BE_DIR" && mvn spring-boot:run) > "$BE_LOG" 2>&1 &
BE_PID=$!
echo "$BE_PID" >> "$PID_FILE"

echo -e "\e[90m  Waiting for backend to be healthy (allow ~60s)...\e[0m"
BE_READY=false
for i in {1..30}; do
    sleep 4
    if ! kill -0 "$BE_PID" 2>/dev/null; then
        echo -e "\e[31m[ERROR] Backend process exited early. Check log:\e[0m"
        echo -e "\e[90m        $BE_LOG\e[0m"
        exit 1
    fi
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/health || true)
    if [ "$STATUS_CODE" -eq 200 ]; then
        BE_READY=true
        break
    fi
done

if [ "$BE_READY" = true ]; then
    echo -e "\e[32m  Backend ready at http://localhost:8080\e[0m"
else
    echo -e "\e[33m  [WARN] Backend did not respond in 2 min — may still be starting.\e[0m"
    echo -e "\e[90m         Tail log: tail -f \"$BE_LOG\"\e[0m"
fi

# Install frontend deps if first run
if [ ! -d "$FE_DIR/node_modules" ]; then
    echo ""
    echo -e "\e[36mRunning npm install (first run only)...\e[0m"
    (cd "$FE_DIR" && npm install)
    echo -e "\e[32m  Done.\e[0m"
fi

# Start Vite dev server
echo ""
echo -e "\e[36mStarting Vite dev server...\e[0m"
FE_LOG="$LOGS_DIR/frontend-$(date +%Y%m%d_%H%M%S).log"

# Run in background and save pid
(cd "$FE_DIR" && npm run dev) > "$FE_LOG" 2>&1 &
FE_PID=$!
echo "$FE_PID" >> "$PID_FILE"

FE_READY=false
for i in {1..15}; do
    sleep 2
    if ! kill -0 "$FE_PID" 2>/dev/null; then
        echo -e "\e[31m[ERROR] Vite process exited. Check: $FE_LOG\e[0m"
        exit 1
    fi
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 || true)
    if [ "$STATUS_CODE" -eq 200 ] || [ "$STATUS_CODE" -eq 304 ]; then
        FE_READY=true
        break
    fi
done

if [ "$FE_READY" = true ]; then
    echo -e "\e[32m  Vite ready at http://localhost:5173\e[0m"
else
    echo -e "\e[33m  [WARN] Vite did not respond in 30s. Check: $FE_LOG\e[0m"
fi

# Summary
echo ""
echo -e "\e[36m==========================================\e[0m"
echo -e "\e[32m  IoT-Sync — Local Services Running\e[0m"
echo -e "\e[36m==========================================\e[0m"
echo ""
echo -e "\e[33m  React (Vite HMR)    http://localhost:5173\e[0m"
echo -e "\e[90m    Login: demo / Pipra\$1234\e[0m"
echo ""
echo -e "\e[33m  Spring Boot API     http://localhost:8080/api\e[0m"
echo -e "\e[90m    Health:  http://localhost:8080/api/health\e[0m"
echo -e "\e[90m    Ingest:  POST http://localhost:8080/api/iot-sync/ingest\e[0m"
echo ""
echo -e "\e[90m  TimescaleDB         localhost:5433  (must be running separately)\e[0m"
echo ""
echo -e "\e[90m  Logs: $LOGS_DIR\e[0m"
echo -e "\e[90m  Stop: ./stop.sh\e[0m"
echo -e "\e[36m==========================================\e[0m"
echo ""

# Attempt to open browser if xdg-open is available
if command -v xdg-open &> /dev/null; then
    xdg-open "http://localhost:5173" &>/dev/null || true
fi
===================================================================
#!/usr/bin/env bash

# IoT-Sync — Start Docker DB
# Starts only the TimescaleDB container.

# Exit on errors
set -e

# Get script directory
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "\e[36m==========================================\e[0m"
echo -e "\e[36m  IoT-Sync — Starting TimescaleDB\e[0m"
echo -e "\e[90m  (Docker DB only)\e[0m"
echo -e "\e[36m==========================================\e[0m"
echo ""

# Pre-flight check
if ! command -v docker &> /dev/null; then
    echo -e "\e[31m[ERROR] Docker not found. Please install Docker.\e[0m"
    exit 1
fi

# Stop DB if already running
if docker ps -a --format '{{.Names}}' | grep -Eq "^iot-sync-db$"; then
    echo -e "\e[90mStopping existing DB container...\e[0m"
    docker compose -f "$ROOT/docker-compose.yml" stop db &>/dev/null || true
    docker compose -f "$ROOT/docker-compose.yml" rm -f db &>/dev/null || true
    echo -e "\e[90m  Stopped.\e[0m"
fi

# Start DB container
echo -e "\e[36mStarting TimescaleDB container...\e[0m"
docker compose -f "$ROOT/docker-compose.yml" up -d db

# Wait for healthy
echo -e "\e[90mWaiting for TimescaleDB to be healthy...\e[0m"
for i in {1..30}; do
    STATUS=$(docker inspect --format='{{.State.Health.Status}}' iot-sync-db 2>/dev/null || echo "unknown")
    if [ "$STATUS" = "healthy" ]; then
        break
    fi
    sleep 2
done

STATUS=$(docker inspect --format='{{.State.Health.Status}}' iot-sync-db 2>/dev/null || echo "unknown")
if [ "$STATUS" != "healthy" ]; then
    echo -e "\e[31m[ERROR] TimescaleDB did not become healthy in time.\e[0m"
    echo -e "\e[90m        Check logs: docker compose logs db\e[0m"
    exit 1
fi

echo ""
echo -e "\e[36m==========================================\e[0m"
echo -e "\e[32m  TimescaleDB ready on localhost:5433\e[0m"
echo -e "\e[36m==========================================\e[0m"
echo ""
echo -e "\e[33m  Next step: run ./start-dev.sh\e[0m"
echo -e "\e[90m  Stop DB:   ./stop.sh\e[0m"
echo -e "\e[36m==========================================\e[0m"
echo ""
============================================================
#!/usr/bin/env bash

# IoT-Sync — Full Docker Stack
# Builds Docker images and starts all three services: DB, Spring Boot app, and React frontend.

# Exit on errors
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$ROOT/.dev-pids"

echo -e "\e[36m==========================================\e[0m"
echo -e "\e[36m  IoT-Sync — Full Docker Stack\e[0m"
echo -e "\e[90m  DB + App + Frontend — all in Docker\e[0m"
echo -e "\e[36m==========================================\e[0m"
echo ""

# Pre-flight check
if ! command -v docker &> /dev/null; then
    echo -e "\e[31m[ERROR] Docker not found. Please install Docker.\e[0m"
    exit 1
fi

# Stop any existing dev processes
if [ -f "$PID_FILE" ]; then
    echo -e "\e[90mStopping local dev processes...\e[0m"
    while read -r pid; do
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            kill -9 -"$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null || true
        fi
    done < "$PID_FILE"
    rm -f "$PID_FILE"
fi

# Stop any existing containers
echo -e "\e[90mStopping any existing containers...\e[0m"
docker compose -f "$ROOT/docker-compose.yml" down --remove-orphans &>/dev/null || true
echo -e "\e[90m  Done.\e[0m"

# Build and start services
echo ""
echo -e "\e[36mBuilding images and starting all services (takes a few minutes on first run)...\e[0m"
docker compose -f "$ROOT/docker-compose.yml" up -d --build

# Wait for TimescaleDB
echo ""
echo -e "\e[90mWaiting for TimescaleDB...\e[0m"
for i in {1..45}; do
    STATUS=$(docker inspect --format='{{.State.Health.Status}}' iot-sync-db 2>/dev/null || echo "unknown")
    if [ "$STATUS" = "healthy" ]; then
        break
    fi
    sleep 2
done
if [ "$STATUS" != "healthy" ]; then
    echo -e "\e[31m[ERROR] TimescaleDB did not become healthy in time.\e[0m"
    echo -e "\e[90m        Check: docker compose logs db\e[0m"
    exit 1
fi
echo -e "\e[32m  TimescaleDB healthy.\e[0m"

# Wait for Spring Boot
echo -e "\e[90mWaiting for Spring Boot backend...\e[0m"
for i in {1..60}; do
    STATUS=$(docker inspect --format='{{.State.Health.Status}}' iot-sync-app 2>/dev/null || echo "unknown")
    if [ "$STATUS" = "healthy" ]; then
        break
    fi
    sleep 3
done
if [ "$STATUS" != "healthy" ]; then
    echo -e "\e[33m  [WARN] Backend may still be starting. Check: docker compose logs app\e[0m"
else
    echo -e "\e[32m  Backend healthy.\e[0m"
fi

# Wait for Frontend
echo -e "\e[90mWaiting for React frontend (nginx)...\e[0m"
FE_READY=false
for i in {1..15}; do
    sleep 2
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 || true)
    if [ "$STATUS_CODE" -eq 200 ]; then
        FE_READY=true
        break
    fi
done
if [ "$FE_READY" = true ]; then
    echo -e "\e[32m  Frontend healthy.\e[0m"
else
    echo -e "\e[33m  [WARN] Frontend may still be starting. Check: docker compose logs frontend\e[0m"
fi

# Summary
echo ""
echo -e "\e[36m==========================================\e[0m"
echo -e "\e[32m  IoT-Sync — Full Stack Running\e[0m"
echo -e "\e[36m==========================================\e[0m"
echo ""
echo -e "\e[33m  IoT-Sync Portal     http://localhost:3000\e[0m"
echo -e "\e[90m    Login: demo / Pipra\$1234  (Admin role)\e[0m"
echo ""
echo -e "\e[33m  Spring Boot API     http://localhost:8080/api\e[0m"
echo -e "\e[90m    Health:  http://localhost:8080/api/health\e[0m"
echo -e "\e[90m    Ingest:  POST http://localhost:8080/api/iot-sync/ingest\e[0m"
echo ""
echo -e "\e[33m  TimescaleDB         localhost:5433  (Docker)\e[0m"
echo -e "\e[90m    DB: iot_sync  User: iot_sync  Pass: iot_sync_pwd\e[0m"
echo ""
echo -e "\e[90m  Container status:   docker compose ps\e[0m"
echo -e "\e[90m  Logs:               docker compose logs -f\e[0m"
echo -e "\e[90m  Stop:               ./stop.sh\e[0m"
echo ""
echo -e "\e[36m  TIP: For development with hot-reload, use ./start-docker-dev.sh\e[0m"
echo -e "\e[36m==========================================\e[0m"
echo ""

# Attempt to open browser if xdg-open is available
if command -v xdg-open &> /dev/null; then
    xdg-open "http://localhost:3000" &>/dev/null || true
fi
============================================================
#!/usr/bin/env bash

# IoT-Sync — Stop Everything
# Stops local Vite / Maven processes and all Docker containers.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$ROOT/.dev-pids"

echo -e "\e[36m==========================================\e[0m"
echo -e "\e[36m  IoT-Sync — Stopping All Services\e[0m"
echo -e "\e[36m==========================================\e[0m"
echo ""

# Stop dev processes (Vite + Maven)
echo -e "\e[90mStopping dev processes...\e[0m"
if [ -f "$PID_FILE" ]; then
    while read -r pid; do
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            kill -9 -"$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null || true
            echo -e "\e[90m  Stopped PID $pid\e[0m"
        fi
    done < "$PID_FILE"
    rm -f "$PID_FILE"
fi

for port in 5173 8080; do
    PIDS=$(lsof -t -i:$port -sTCP:LISTEN 2>/dev/null || true)
    if [ -n "$PIDS" ]; then
        for pid in $PIDS; do
            kill -9 "$pid" 2>/dev/null || true
        done
        echo -e "\e[90m  Cleared port $port.\e[0m"
    fi
done
echo -e "\e[32m  Dev processes stopped.\e[0m"

# Stop Docker stack
echo ""
echo -e "\e[90mStopping Docker containers...\e[0m"
docker compose -f "$ROOT/docker-compose.yml" down
if [ $? -eq 0 ]; then
    echo -e "\e[32m  All containers stopped.\e[0m"
else
    echo -e "\e[33m  [WARN] docker compose down returned an error (containers may not have been running).\e[0m"
fi

echo ""
echo -e "\e[90m  IoT-Sync fully stopped.\e[0m"
echo -e "\e[36m==========================================\e[0m"
echo ""
============================================================================