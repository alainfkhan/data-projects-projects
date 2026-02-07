use olist_stg;

select top (1000)
*
from sales.dim_products;


select top (1000)
    *
from sales.dim_product_category_name_translation;

select count(*)
from marketing.fact_closed_deals;
/* not inserted:
4000656 [1000164, 4] logistics.dim_geolocation

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

1380764 total rows
5746458 total cells
*/