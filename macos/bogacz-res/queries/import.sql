/*
to run this file:
$ sqlite3 data/db/data.db < queries/import.sql
or
sqlite> .shell sqlite3 data/db/data.db < queries/import.sql
*/

-- drop tables
DROP TABLE IF EXISTS future50_raw;
DROP TABLE IF EXISTS independence100_raw;
DROP TABLE IF EXISTS top250_raw;
DROP TABLE IF EXISTS usps_raw;
DROP TABLE IF EXISTS usgpo_raw;
DROP TABLE IF EXISTS CARegions;

-- noqa:disable=all

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
.import data/external/ca-regions.csv CARegions