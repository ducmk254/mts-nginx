#!/bin/bash

backup_path=s3://mutosi-metabase-backup
expiry_date=7
current_date=$(date +'%Y-%m-%d')
folder_backup=/opt/metabase-nginx
# create folder via day
cd $folder_backup
docker compose down

echo "$(date +'%Y-%m-%d %H:%M:%S'): metabase nginx stopped." >> $folder_backup/script.logs

zip_filename="${current_date}.zip"
zip -r "${zip_filename}" $folder_backup

echo "$(date +'%Y-%m-%d %H:%M:%S'): folder zip finished." >> $folder_backup/script.logs


cd $folder_backup
docker compose up -d
echo "$(date +'%Y-%m-%d %H:%M:%S'): metabase nginx running ...." >> $folder_backup/script.logs
s3cmd put -r -f $folder_backup/"${zip_filename}" $backup_path/
echo "$(date +'%Y-%m-%d %H:%M:%S'): put to s3 finish " >> $folder_backup/script.logs
rm -rf  $folder_backup/"${zip_filename}"
echo "$(date +'%Y-%m-%d %H:%M:%S'): remove file zip --> done" >> $folder_backup/script.logs

# delete folder backup older than expiry_date day
#find $backup_path -type d -mtime +$expiry_date | xargs rm -Rf
