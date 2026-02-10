-- get current db
select db_name()

use master
use olist_stg

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

-- show all tables
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
