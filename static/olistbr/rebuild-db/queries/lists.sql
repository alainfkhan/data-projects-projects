-- get current db
SELECT DB_NAME()

USE master
USE olist_stg
USE deletesoon

GO;

CREATE SCHEMA some_schema;

GO;

CREATE TABLE some_schema.table_name (
    a INT,
    b VARCHAR(20)
)
INSERT INTO some_schema.table_name
VALUES (10, 'test')

SELECT * FROM some_schema.table_name

-- list all dbs
SELECT name FROM master.sys.databases

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
SELECT name
FROM sys.schemas
WHERE schema_id BETWEEN 5 AND 16383;
GO

-- list schemas in any database

-- list tables in connected-to database
SELECT
TABLE_CATALOG,
TABLE_SCHEMA,
TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
GO

-- list tables in schema
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'sales'


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
select top 1000 * from logistics.fact_geolocation;

select * from core.dim_date;
*/

-- count rows
SELECT COUNT(*) FROM sales.dim_customers

-- count columns
SELECT COUNT(*) FROM INFORMATION_SCHEMA.columns
WHERE TABLE_SCHEMA = 'sales'
AND TABLE_NAME = 'dim_customers'

SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS


-- get total reviews by score
SELECT
    r.review_score,
    COUNT(*) AS total_reviews
FROM sales.fact_order_reviews AS r
GROUP BY r.review_score
ORDER BY r.review_score DESC;
GO

USE olist_stg

SELECT TOP 1000 * FROM sales.dim_sellers s
WHERE s.seller_id = 'c0f3eea2e14555b6faeea3dd58c1b1c3'
