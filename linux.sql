Linux find any value on folder lavel :-
 * grep -r -E 'localhost' /opt/idempiere-server/

Cronjob command:-
 * sudo crontab -e   (edit cron job) 
 * 0 6 1 * * /opt/idempiere-server/remove-log-script.sh
  (every month 6 AM run this script)


script:-
 #!/bin/bash

 # Directory containing backup files
 BACKUP_DIR="log/"

 # Keep the 15 most recent backup files
 find "$BACKUP_DIR" -name "idempiere*" -type f | \
 sort -r | \
 tail -n +15 | \
 xargs -d '\n' rm -f --

 echo "Deleted all but the 15 most recent database backup files"	  


