# PiERP Custom Plugin Deployment Guide

This guide details the step-by-step workflow for compiling and deploying custom OSGi plugins into the PiERP ecosystem under two conditions:

1. When Docker containers are already running (Hot Deploy)
2. When Docker containers are stopped (Cold Deploy)

---

# Guide 1: When Docker Containers ARE Running (Hot Deploy)

Use this method when you want to quickly deploy code updates, register widgets, or run database migrations without tearing down the entire Docker network.

## Step 1: Compile the Plugin

Run the plugin build script to clean, compile, package, and stage the plugin JAR.

### Run the build script

```bash
pwsh /home/chirag/PiERP/pi-erp/pi-erp-plugins/build_plugins.ps1
```

### Interactive Options

- Choose **S (Specific)** to build only your plugin (e.g., `com.pipra.dashboard.3dlayout`)
- Choose **A (All)** to build all plugins
- Select **Migration Mode** if your plugin contains SQL migrations under:

```text
migration/postgresql/sql-migrations/
```

---

## Step 2: Deploy the Plugin

After the build completes successfully and stages the JAR files under:

```text
docker-image/image-builder/build-plugins/
```

Run:

```bash
pwsh /home/chirag/PiERP/pi-erp/docker-image/image-builder/deploy_plugins.ps1
```

### What deploy_plugins.ps1 does automatically

- Copies compiled JARs into the running container:

```text
/opt/idempiere/plugins/
```

- Updates plugin registration in:

```text
/opt/idempiere/configuration/org.eclipse.equinox.simpleconfigurator/bundles.info
```

- Clears Equinox OSGi bundle cache

- Copies and executes pending SQL migrations in:

```text
pi-erp-db-v10
```

- Restarts:

```text
pi-erp-server-v10
```

- Waits for WebUI to become available

---

## Step 3: Run Manual Database Scripts (Optional)

If your plugin requires a manual database setup script (such as `warehouse_3d_layout_widget.sql`) that is not packaged in Tycho migrations:

### Copy SQL file

```bash
docker cp /home/chirag/PiERP/pi-erp/pi-erp-plugins/warehouse_3d_layout_widget.sql pi-erp-db-v10:/tmp/
```

### Execute SQL file

```bash
docker exec -i pi-erp-db-v10 psql -U adempiere -d idempiere -f /tmp/warehouse_3d_layout_widget.sql
```

---

# Guide 2: When Docker Containers ARE NOT Running (Cold Deploy)

Use this method if:

- Containers are offline
- Starting from a clean environment
- Rebuilding infrastructure

---

## Step 1: Compile the Plugin

Run:

```bash
pwsh /home/chirag/PiERP/pi-erp/pi-erp-plugins/build_plugins.ps1
```

This will:

- Build plugin JARs
- Stage deployment files
- Update:

```text
custom-bundles.info
```

Located in:

```text
image-builder/build-plugins/
```

---

## Step 2: Start the Containers

Navigate to:

```bash
cd /home/chirag/PiERP/pi-erp/docker-image/pi-erp-distribution
```

Run:

```bash
bash PiERP_Docker_Run.sh
```

### How Offline Injection Works

The `docker-compose.yml` mounts:

```text
inject-plugins.sh
```

During startup:

1. Container entrypoint executes `inject-plugins.sh`
2. Script merges entries from:

```text
custom-bundles.info
```

into:

```text
bundles.info
```

3. iDempiere starts with all custom plugins already registered

---

## Step 3: Apply Database Configurations

After containers are running:

```bash
pwsh /home/chirag/PiERP/pi-erp/docker-image/image-builder/deploy_plugins.ps1
```

This executes pending SQL migrations.

### Alternative: Run Manual SQL Scripts

Copy file:

```bash
docker cp /home/chirag/PiERP/pi-erp/pi-erp-plugins/warehouse_3d_layout_widget.sql pi-erp-db-v10:/tmp/
```

Execute:

```bash
docker exec -i pi-erp-db-v10 psql -U adempiere -d idempiere -f /tmp/warehouse_3d_layout_widget.sql
```

---

# Crucial Tips to Avoid Common Mistakes

## IMPORTANT

### Check bundles.info Line Breaks

Ensure that no empty or whitespace-only lines exist in:

```text
bundles.info
```

either on:

- Host machine
- Docker container

Invalid blank lines can cause:

```text
ContainerTldBundleDiscoverer
```

to throw:

```text
NullPointerException
```

which prevents server startup.

---

## WARNING

### Avoid Shadowing Container JARs with Empty Folders

Never volume-mount individual JAR files that do not exist on the host.

If Docker cannot find the host file:

- Docker automatically creates an empty directory
- That directory shadows the actual JAR inside the container

This can lead to:

```text
ClassNotFoundException
NoClassDefFoundError
Plugin startup failures
```

---

## NOTE

### Database ID Conflicts

When writing SQL preference or registration scripts:

Avoid hardcoded IDs that may already exist.

Examples:

```sql
AD_Preference_ID
AD_DashboardContent_ID
AD_Menu_ID
```

Recommended approaches:

- Use sequence-generated IDs
- Query next sequence value dynamically
- Reserve IDs above existing ranges

This prevents:

```text
Duplicate key violations
Migration failures
Deployment rollback issues
```

---

# Quick Reference

## Hot Deploy

```bash
pwsh /home/chirag/PiERP/pi-erp/pi-erp-plugins/build_plugins.ps1

pwsh /home/chirag/PiERP/pi-erp/docker-image/image-builder/deploy_plugins.ps1
```

---

## Cold Deploy

```bash
pwsh /home/chirag/PiERP/pi-erp/pi-erp-plugins/build_plugins.ps1

cd /home/chirag/PiERP/pi-erp/docker-image/pi-erp-distribution

bash PiERP_Docker_Run.sh

pwsh /home/chirag/PiERP/pi-erp/docker-image/image-builder/deploy_plugins.ps1
```

---

## Manual SQL Execution

```bash
docker cp warehouse_3d_layout_widget.sql pi-erp-db-v10:/tmp/

docker exec -i pi-erp-db-v10 psql -U adempiere -d idempiere -f /tmp/warehouse_3d_layout_widget.sql
```