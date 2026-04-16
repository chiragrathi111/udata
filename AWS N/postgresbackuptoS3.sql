postgresdb backup and store the s3 file:-

nano ~/.pgpass

localhost:5432:realmeds:postgres:YourPassword

chmod 600 ~/.pgpass

------------------------------------------------------

#!/bin/bash
set -e

DATE=$(date '+%Y-%m-%d_%H-%M-%S')

DB_NAME="realmeds"
BACKUP_DIR="/home/ubuntu/backup"
FILE_NAME="db_backup_$DATE.sql"
LOG_FILE="/home/ubuntu/backup.log"
S3_BUCKET="s3://demobackup121"

# Step 1: Backup
pg_dump -U postgres $DB_NAME > $BACKUP_DIR/$FILE_NAME

if [ $? -ne 0 ]; then
  echo "[$DATE] Backup FAILED" >> $LOG_FILE
  exit 1
fi

# Step 2: Compress
gzip $BACKUP_DIR/$FILE_NAME
FINAL_FILE="$BACKUP_DIR/$FILE_NAME.gz"

# Check file exists
if [ ! -f "$FINAL_FILE" ]; then
  echo "[$DATE] Backup file missing" >> $LOG_FILE
  exit 1
fi

# Step 3: Upload with retry
for i in {1..3}
do
  aws s3 cp "$FINAL_FILE" "$S3_BUCKET/" --only-show-errors && break
  echo "[$DATE] Upload retry $i failed" >> $LOG_FILE
  sleep 15
done

# Step 4: Check upload success
if [ $? -eq 0 ]; then
  echo "[$DATE] Upload successful" >> $LOG_FILE
else
  echo "[$DATE] Upload FAILED after retries" >> $LOG_FILE
fi

# Step 5: Cleanup
find $BACKUP_DIR -type f -mtime +7 -name "*.gz" -delete