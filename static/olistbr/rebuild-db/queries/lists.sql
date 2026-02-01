-- get current db
select db_name()

use master
use olist_stg

-- list all dbs
select name from master.sys.databases 

-- list all schemas in db
select name
from sys.schemas
where schema_id between 5 and 16383
