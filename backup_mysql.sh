#!/bin/bash

# vars
dbs=$(mysql -u root -e 'show databases;' | awk '{ print $1 }' | egrep -v 'Database|information_schema|performance_schema|mysql')
date=$(date +%Y%m%d_%H%M)
backup_folder="/srv/backup/mysql/"
count="3"

# test if folder exist, if not create it
test -d $backup_folder || mkdir -p $backup_folder

# dump all databases
for database in $dbs
do
  mysqldump -u root $database | gzip > $backup_folder$date\_$database.sql.gz
  # keep only x files
  ls -1t /srv/backup/mysql/*$database.sql.gz | tail -n +$((count+1)) | xargs rm -f
done
