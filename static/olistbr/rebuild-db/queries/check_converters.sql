/*
columns that require converters

sales.dim_customers
    customer_zip_code_prefix: str

sales.dim_sellers
    seller_zip_code_prefix: str

logistics.fact_geolocation
    geolocation_zip_code_prefix: str
*/

use olist_stg

select top 1000
*
from sales.dim_customers;

select top 1000
*
from sales.dim_sellers;

select
    count(*)
from logistics.dim_cep_iz_AuBmA;


select
    count(*)
from logistics.dim_cep_iz_B;