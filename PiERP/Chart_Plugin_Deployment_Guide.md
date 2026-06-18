# Chart Plugin Deployment Guide

## Overview

Whenever changes are made to the `com.pipra.chart.dashboard` plugin, follow the steps below to build and deploy the updated plugin to your local PiERP environment.

---

## Step 1: Update Plugin Version

Open the version file:

```text
/home/chirag/PiERP/pi-erp/pi-erp-plugins/com.pipra.chart.dashboard/migration/postgresql/packin/pack-version.txt
```

Increment the version number.

Example:

```text
1.0.0 → 1.0.1
1.0.1 → 1.0.2
1.0.2 → 1.0.3
```

This ensures the migration is detected and executed during deployment.

---

## Step 2: Build the Plugin

Navigate to the plugins directory:

```bash
cd /home/chirag/PiERP/pi-erp/pi-erp-plugins
```

Run the build script:

```bash
pwsh build_plugins.ps1
```

### Build Options

When prompted:

```text
Select Build Mode: S
```

Enter plugin name:

```text
com.pipra.chart.dashboard
```

Select migration type:

```text
P
```

(P = Packin Mode)

---

### Automated Build Command

```bash
echo -e "S\ncom.pipra.chart.dashboard\nP\n" | pwsh build_plugins.ps1
```

---

## Step 3: Deploy the Plugin

Navigate to:

```bash
cd /home/chirag/PiERP/pi-erp/docker-image/image-builder
```

Run:

```bash
pwsh deploy_plugins.ps1
```

When prompted select:

```text
A
```

(A = Deploy All Compiled Plugins)

---

### Automated Deploy Command

```bash
echo "A" | pwsh deploy_plugins.ps1
```

---

## What Happens During Deployment?

The deployment script automatically:

1. Copies the latest plugin JAR to the server container.
2. Updates the bundle registry.
3. Clears OSGi cache.
4. Restarts the PiERP server.
5. Detects the new PackIn version.
6. Executes pending SQL migrations automatically.
7. Loads the updated plugin bundle.

---

## Quick Build & Deploy

### Build

```bash
cd /home/chirag/PiERP/pi-erp/pi-erp-plugins

echo -e "S\ncom.pipra.chart.dashboard\nP\n" | pwsh build_plugins.ps1
```

### Deploy

```bash
cd /home/chirag/PiERP/pi-erp/docker-image/image-builder

echo "A" | pwsh deploy_plugins.ps1
```

---

## Checklist Before Deployment

* [ ] Code changes completed
* [ ] SQL migration added (if required)
* [ ] pack-version.txt updated
* [ ] Plugin builds successfully
* [ ] No compilation errors
* [ ] Deployment completed successfully
* [ ] Server restarted successfully
* [ ] Migration executed successfully
* [ ] Functionality verified in PiERP

---

## Troubleshooting

### Migration Not Executed

Verify:

```text
migration/postgresql/packin/pack-version.txt
```

Version must be incremented.

---

### Changes Not Visible

Clear browser cache and verify that:

```bash
pwsh deploy_plugins.ps1
```

completed successfully.

---

### Plugin Not Loaded

Check server logs for:

```text
BundleException
ClassNotFoundException
NoClassDefFoundError
```

and resolve dependency issues before redeploying.

---

## Plugin Information

Plugin Name:

```text
com.pipra.chart.dashboard
```

Build Mode:

```text
Specific Plugin (S)
```

Migration Type:

```text
PackIn (P)
```

Deployment Mode:

```text
All Compiled Plugins (A)
```
