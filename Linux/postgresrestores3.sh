#!/bin/bash

# Set the database name and the backup file name
DB_NAME="clarityrx"

BACKUP_FILE="/home/ubuntu/restoreData/postgres_realmeds_2023-05-15_00:00.sql"

# Set the username and password for the database
DB_USERNAME="postgres"

DB_PASSWORD="Pipra@1234"

psql --dbname=postgresql://$DB_USERNAME:$DB_PASSWORD@localhost:5432/$DB_NAME -f $BACKUP_FILE
# clarityrx_user