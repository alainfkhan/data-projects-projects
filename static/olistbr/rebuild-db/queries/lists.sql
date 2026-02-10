-- get current db
select db_name()

use master
use olist_stg
use deletesoon

create schema some_schema;

create table some_schema.table_name (
    a INT,
    b varchar(20)
)
insert into some_schema.table_name
values (10, 'test')

select * from some_schema.table_name

-- list all dbs
select name from master.sys.databases 

-- drop schemas
/*
drop schema sales;
go
drop schema marketing;
go
drop schema logistics;
go
*/

-- list all schemas in connected-to database
select name
from sys.schemas
where schema_id between 5 and 16383;
go

-- list schemas in any database

-- list tables in connected-to database
select TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME
from INFORMATION_SCHEMA.TABLES
go

-- list tables in schema
select TABLE_NAME
from INFORMATION_SCHEMA.TABLES
where TABLE_SCHEMA = 'sales'



--
/*
select top 1000 * from sales.dim_customers;
select top 1000 * from sales.dim_sellers;
select top 1000 * from sales.dim_product_category_name_translation;
select top 1000 * from sales.dim_products;
select top 1000 * from sales.fact_orders;
select top 1000 * from sales.fact_order_items;
select top 1000 * from sales.fact_order_payments;
select top 1000 * from sales.fact_order_reviews;
select top 1000 * from marketing.fact_marketing_qualified_leads;
select top 1000 * from marketing.fact_closed_deals;
select top 1000 * from logistics.dim_geolocation;
*/

-- count rows
select count(*) from sales.dim_customers

-- count columns
select count(*) from INFORMATION_SCHEMA.columns
where TABLE_SCHEMA = 'sales'
and TABLE_NAME = 'dim_customers'

SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS



-- get total reviews by score
select
    r.review_score,
    count(*) as total_reviews
from sales.fact_order_reviews as r
group by r.review_score
order by r.review_score desc;
go

use olist_stg

select top 1000 * from sales.dim_sellers s
where s.seller_id = 'c0f3eea2e14555b6faeea3dd58c1b1c3'
