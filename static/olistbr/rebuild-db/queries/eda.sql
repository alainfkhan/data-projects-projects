use olist_stg;

select *
from INFORMATION_SCHEMA.tables

select top 1000
    *
from sales.dim_customers

select top (1000)
    *
from logistics.dim_geolocation;

select top (1000)
    *
from marketing.fact_closed_deals;

-- drop table marketing.fact_closed_deals

-- truncate table marketing.fact_closed_deals

select count(*)
from marketing.fact_closed_deals;
/*
inserted:
49705 [9941, 5] sales.dim_customers
12380 [3095, 4] sales.dim_sellers
142 [71, 2] sales.dim_product_category_name_translation
296559 [32951, 9] sales.dim_products
79528 [9941, 8] sales.fact_orders
788550 [112650, 7] sales.fact_order_items
519425 [103885, 5] sales.fact_order_payments
694568 [99224, 7] sales.fact_order_reviews
3200 [8000, 4] marketing.fact_marketing_qualified_leads
11536 [842, 14] marketing.fact_closed_deals
4000656 [1000164, 4] logistics.dim_geolocation

1380764 total rows
5746458 total cells
*/