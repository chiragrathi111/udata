#!/bin/bash

date=$(date '+%F_%H:%M')

# Set the database name and the backup file name
-- DB_NAME="clarityrx"
DB_NAME="postgres"

BACKUP_FILE="/mnt/datas/backup/postgresql_realmeds_"${date}".sql"

# Set the username and password for the database
DB_USERNAME="postgres"

DB_PASSWORD="postgres"
-- DB_PASSWORD="Pipra@1234"

# Dump the database to a file
pg_dump --no-owner --dbname=postgresql://$DB_USERNAME:$DB_PASSWORD@localhost:5432/$DB_NAME > $BACKUP_FILE
#pg_dump -U $DB_USERNAME -w $DB_NAME > $BACKUP_FILE

-- aws s3 cp $BACKUP_FILE s3://demobackup121/

echo "Database has been done on ${date}" >> /tmp/backup_log_${date}.log

sudo mkdir -p /mnt/data/backup
sudo chown -R ubuntu:ubuntu /mnt/data
sudo chmod -R 755 /mnt/data


#################
gunzip postgresql_realmeds_2026-01-05_1320.sql.gz
psql -U postgres -d clarityrx < postgresql_realmeds_2026-01-05_1320.sql


30 05 * * * /home/ubuntu/script/db_backup.sh >> /var/log/pg_backup.log 2>&1