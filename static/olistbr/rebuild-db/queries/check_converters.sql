/*
columns that require converters

sales.dim_customers
    customer_zip_code_prefix: str

sales.dim_sellers
    seller_zip_code_prefix: str

logistics.fact_geolocation
    geolocation_zip_code_prefix: str
*/

USE olist_stg

SELECT TOP 1000 *
FROM sales.dim_customers;

SELECT TOP 1000 *
FROM sales.dim_sellers;

SELECT COUNT(*)
FROM logistics.dim_cep_iz_AuBmA;


SELECT COUNT(*)
FROM logistics.dim_cep_iz_B;
