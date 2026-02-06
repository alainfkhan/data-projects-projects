use olist_stg;

select top (1)
*
from sales.dim_customers;

select top (1000)
    *
from sales.dim_product_category_name_translation;

/* not inserted:
sales.dim_products
sales.fact_orders
sales.fact_order_items
sales.fact_order_payments
sales.fact_order_reviews
marketing.fact_marketing_qualified_leads
marketing.fact_closed_deals
logistics.dim_geolocation

inserted:
sales.dim_customers
sales.dim_sellers
sales.dim_product_category_name_translation
*/