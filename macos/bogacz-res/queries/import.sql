/*
to run this file:
$ sqlite3 data/db/data.db < queries/import.sql
or
sqlite> .shell sqlite3 data/db/data.db < queries/import.sql
*/

-- drop tables
drop table if exists future50_raw;
drop table if exists independence100_raw;
drop table if exists top250_raw;
drop table if exists usps_raw;
drop table if exists usgpo_raw;

-- import fact tables
.mode csv
.import data/raw/Future50.csv future50_raw
.import data/raw/Independence100.csv independence100_raw
.import data/raw/Top250.csv top250_raw

-- import dim tables
.separator |
.import data/external/us-states.psv usps_raw
.separator ,

.import data/external/usgpo.csv usgpo_raw

-- .import data/external/