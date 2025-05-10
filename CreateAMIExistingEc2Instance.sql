1. Create AMI in Existing Ec2 instance
2. Create Ec2 instance help of AMI (Backup & Restore)
3. Create Volume 50GB 
4. Attach Volume in Ec2 instance
5. Mount Volume and Ec2 instance (/backup)
6. Create Script backup from postgresql to /backup (backup_script.sh)
7. Create Cronjob backup_script automation 
8. Create S3 bucket (demobackup121)
9. Create IAM Role(ec2-s3-fullAccess)
10.Attach IAM role in Ec2 instance
11.Create Script backup another copy file in S3 (volumeToS3Backup.sh)
12.Craete Cronjob copy S3 in automation
13.Create Script Before 7 days file remove (removeFileBeforeSevenDays.sh) 

--------------------------------------------------------------------------------------------------------------------------------------


///////////////// backup script \\\\\\\\\\\\\\\
#!/bin/bash

date=$(date '+%Y-%m-%d_%H:%M:%S')

# Set the database name and the backup file name
DB_NAME="realmeds"
BACKUP_FILE="/home/ubuntu/backup/database_backup_"${date}".sql"

# Set the username and password for the database
DB_USERNAME="postgres"
DB_PASSWORD="VndDhmNTum"

# Dump the database to a file
pg_dump --no-owner --dbname=postgresql://$DB_USERNAME:$DB_PASSWORD@localhost:5432/$DB_NAME > $BACKUP_FILE
#pg_dump -U $DB_USERNAME -w $DB_NAME > $BACKUP_FILE
echo "Database has been done on ${date}" >> /tmp/backup_log_${date}.log

------------------------------------------------------------------------------------------------------------------------------------------
////////////////// s3 copy code \\\\\\\\\\\\\\\\\\\\

#!/bin/bash

date=$(date '+%Y-%m-%d_%H:%M:%S')

aws s3 cp /home/ubuntu/backup/database_backup_2023-04-21_10:30:01.sql s3://demobackup121/backup_${date}.sql

--------------------------------------------------------------------------------------------------------------------------------------------
//////////////// 7 day before file remove \\\\\\\\\\\\\\\\\

#!/bin/bash

find /backup/ -name "database_backup.sql*" -mtime +7  -exec rm {} \;

---------------------------------------------------------------------------------------------------------------------------------------------
//////////// restore database \\\\\\\\\\\\\\\\\\\

#!/bin/bash

# Set the database name and the backup file name
DB_NAME="db"
BACKUP_FILE="/home/ubuntu/downloads/restore_backup.sql"

# Set the username and password for the database
DB_USERNAME="postgres"
DB_PASSWORD="VndDhmNTum"

psql --dbname=postgresql://$DB_USERNAME:$DB_PASSWORD@localhost:5432/$DB_NAME -f $BACKUP_FILE
('psql' ka use pline text formet ke karan kiya hai otherwise 'pq_restore' ka use kiya jata hai)

-------------------------------------------------------------------------------------------------------------------------------------------------
//////////// restore data through S3 \\\\\\\\\\\\\

#!/bin/bash

date=$(date '+%F_%H:%M:%S')
aws s3 cp s3://demobackup121/backup_2023-04-24_11:36:58.sql /home/ubuntu/downloads/restoreData_${date}.sql 

------------------------------------------------------------------------------------------------------------------------------------------------


#CREATE DATABASE db;
#DROP DATABASE db;
(Capital latter and last mai semicolon dono important hai)

