#!/bin/bash


#create the statements from the table
mysql -u reminderly -p'Rem!nDerly123!$' reminderly -s < generate_new_log_table_statements.sql > tmp_create_new_log_tables.sql

#create our new tables
mysql -u reminderly -p'Rem!nDerly123!$' reminderly < tmp_create_new_log_tables.sql

#done with creating and renaming tables
rm tmp_create_new_log_tables.sql

#backup the log tables
DATE=$(date +"%Y%m%d")
mysql -u reminderly -p'Rem!nDerly123!$' -NB information_schema -e "select table_name from tables where table_name like 'drop\_%'" | xargs -I"{}" mysqldump -u reminderly -p'Rem!nDerly123!$' reminderly "{}" | gzip -c > log_backups_$DATE.gz

#drop em
mysql -u reminderly -p'Rem!nDerly123!$' -NB information_schema -e "select table_name from tables where table_name like 'drop\_%'" | xargs -I"{}" mysql -u reminderly -p'Rem!nDerly123!$' reminderly -e "DROP TABLE {}" 