/*
sales.dim_customers
sales.dim_sellers
sales.dim_product_category_name_translation
sales.dim_products
sales.fact_orders
sales.fact_order_items
sales.fact_order_payments
sales.fact_order_reviews
marketing.fact_marketing_qualified_leads
marketing.fact_closed_deals
logistics.dim_geolocation
*/

SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
GO

SELECT *
FROM MASTER.SYS.DATABASES
WHERE OWNER_SID != 0X01;
