#!/bin/bash
# pwd only works if i run the script in the correct directory

DATA_PATH="$(pwd)/data/raw"
SERVER='localhost'
DB_NAME='olist'
DB_STG_NAME=$DB_NAME'_stg'

# sqlcmd -C -S $SERVER -E -Q 'select @@servername;'
# sqlcmd -C -S $SERVER -E -i queries/build-db/000_recreate_db.sql -v DB_STG_NAME=$DB_STG_NAME
sqlcmd -C -S $SERVER -E -i queries/dev/0_test.sql
sqlcmd -C -S $SERVER -E -i queries/dev/1_test.sql