/*
$ sqlite3 data/db/data.db
$ cd data/raw
sqlite> .mode csv
sqlite> .import Future50.csv future50_raw
sqlite> .import Independence100.csv independence100_raw
sqlite> .import Top250.csv top250_raw
*/

.mode csv
.import data/raw/Future50.csv future50_raw
.import data/raw/Independence100.csv independence100_raw
.import data/raw/Top250.csv top250_raw