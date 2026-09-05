#!/bin/bash
set -e

# Configuration
DB_CONTAINER="kuyil-db-1"
DB_NAME="beyondboard"
DB_USERNAME="postgres"
DB_PASSWORD="576adb62832ff296c02c10ea2078f2b1"

# Path Configuration
BACKUP_DIR="/home/kuyiluser/backup"
LOG_DIR="/tmp"

# Safe filename date format (colons replaced with hyphens for filesystem compatibility)
DATE=$(date '+%Y-%m-%d_%H-%M-%S')

BACKUP_FILE="${BACKUP_DIR}/database_backup_${DATE}.sql"
LOG_FILE="${LOG_DIR}/backup_log_${DATE}.log"

# Ensure target directory exists
mkdir -p "${BACKUP_DIR}"

# Run pg_dump inside container and pipe to host file
docker exec -e PGPASSWORD="${DB_PASSWORD}" "${DB_CONTAINER}" \
  pg_dump --no-owner -U "${DB_USERNAME}" -d "${DB_NAME}" > "${BACKUP_FILE}"

# Compress the backup file to save space
gzip -f "${BACKUP_FILE}"
BACKUP_FILE="${BACKUP_FILE}.gz"

# Log completion
echo "[${DATE}] Backup completed successfully: ${BACKUP_FILE}" >> "${LOG_FILE}"

# Retention Policy: Delete backups older than 7 days (uncomment line below to enable)
# find "${BACKUP_DIR}" -type f -name "database_backup_*.sql.gz" -mtime +7 -delete

nano /home/kuyiluser/backup.sh


reate target folder
mkdir -p "${BACKUP_DIR}"

# Run pg_dump at lowest CPU & I/O priority (Idle mode)
nice -n 19 ionice -c 3 docker exec -e PGPASSWORD="${DB_PASSWORD}" "${DB_CONTAINER}" \
  pg_dump --no-owner -U "${DB_USERNAME}" -d "${DB_NAME}" > "${BACKUP_FILE}"

# Compress to save disk space with low CPU usage
nice -n 19 gzip -f "${BACKUP_FILE}"

# Log result
echo "[${DATE}] Weekly backup finished successfully." >> "${LOG_FILE}"

# Retention: Remove backups older than 30 days (4-5 weekly backups kept)
find "${BACKUP_DIR}" -type f -name "database_backup_*.sql.gz" -mtime +30 -delete

0 1 * * 0 /home/kuyiluser/backup.sh > /dev/null 2>&1
