#!/bin/bash

date=$(date '+%F_%H:%M')

# Set the database name and the backup file name
DB_NAME="clarityrx"

BACKUP_DIR="/mnt/data/backup"
BACKUP_FILE="${BACKUP_DIR}/postgresql_${date}.sql.gz"

# Set the username and password for the database
DB_USERNAME="postgres"

DB_PASSWORD="Pipra-cogito"

# Dump the database to a file
pg_dump --no-owner --dbname=postgresql://$DB_USERNAME:$DB_PASSWORD@localhost:5432/$DB_NAME | gzip > $BACKUP_FILE
#pg_dump -U $DB_USERNAME -w $DB_NAME > $BACKUP_FILE

aws s3 cp $BACKUP_FILE s3://cogito-videos-new/

echo "Database has been done on ${date}" >> /tmp/backup_log_${date}.log
