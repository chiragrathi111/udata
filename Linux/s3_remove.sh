#!/bin/bash

DATE=$(date -d "7 days ago" '+%F')

aws s3 rm s3://demobackup121/ --recursive --exclude "*" \
        --include "realmeds_label_"$DATE".tar.gz" \
        --include "realmeds-selfcare_output_"$DATE".tar.gz" \
        --include "current_couchdb_realmeds_"$DATE".tar.gz" \
        --include "postgresql_realmeds_"$DATE"_00:00.sql" \
        --include "postgresql_realmeds_"$DATE"_12:00.sql" \
	--include "couchdb_realmeds_"$DATE".tar.gz"
