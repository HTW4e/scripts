#!/bin/bash

###############################################################################################################
# Description: backup all mysql dbs on host
# Author: HTW4e
# Version: 1.0
# Script Name: backup_mysql.sh
###############################################################################################################
# Copyright (c) HTW4e <htw4e@htw4e.li>

# This software is licensed to you under the GNU General Public License.
# There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/gpl.txt

# vars
dbs=$(mysql -u root -e 'show databases;' | awk '{ print $1 }' | egrep -v 'Database|information_schema|performance_schema|mysql')
date=$(date +%Y%m%d_%H%M)
backup_folder="/srv/backup/mysql/"
count="3"

# test if folder exist, if not create it
test -d $backup_folder || mkdir -p $backup_folder

# dump all databases
for db in $dbs
do
  mysqldump -u root $db | gzip > $backup_folder$date\_$db.sql.gz
  # keep only x files
  ls -1t $backup_folder*$db.sql.gz | tail -n +$((count+1)) | xargs rm -f
done
