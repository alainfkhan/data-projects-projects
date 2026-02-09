-- get current db
select db_name()

use master
use olist_stg

-- list all dbs
select name from master.sys.databases 

-- drop schemas
drop schema sales;
go
drop schema marketing;
go
drop schema logistics;
go

-- list all schemas in db
select name
from sys.schemas
where schema_id between 5 and 16383;
go


-- list all tables in db
select *
from INFORMATION_SCHEMA.TABLES
where TABLE_TYPE='BASE TABLE';
go

use olist_stg

select top 1000 * from sales.dim_sellers s
where s.seller_id = 'c0f3eea2e14555b6faeea3dd58c1b1c3'
