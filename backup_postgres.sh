#!/bin/bash

# vars
dbs=$(psql -U postgres template1 -c "\l" | tail -n+4 | cut -d'|' -f 1 | sed -e '/^ *$/d' | sed -e '$d' | egrep -v 'postgres|template')
date=$(date +%Y%m%d_%H%M)
backup_folder="/srv/backup/pgsql/"
count="3"

# test if folder exist, if not create it
test -d $backup_folder || mkdir -p $backup_folder

# dump all databases
for db in $dbs
do
  pg_dump -U postgres $db | gzip > $backup_folder$date\_$db.sql.gz
  # keep only x files
  ls -1t $backup_folder*$db.sql.gz | tail -n +$((count+1)) | xargs rm -f
done
