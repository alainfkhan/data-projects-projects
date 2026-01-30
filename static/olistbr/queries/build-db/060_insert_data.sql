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
USE olist_stg;
GO

DECLARE @project_path VARCHAR(100)
    = 'C:\\Users\alain\dev\personal\data-projects\dp-projects\static\olistbr';

DECLARE @data_path VARCHAR(100)
    = @project_path + '\data\raw';

BULK INSERT sales.fact_order_items
FROM 'C:\\Users\alain\dev\personal\data-projects\dp-projects\static\olistbr\data\raw\olist_order_items_dataset.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

print @data_path

select * from marketing.fact_marketing_qualified_leads;
drop table marketing.fact_marketing_qaulified_leads

-- SELECT *
-- FROM INFORMATION_SCHEMA.TABLES
-- WHERE TABLE_TYPE = 'BASE TABLE';
-- GO

-- SELECT *
-- FROM MASTER.SYS.DATABASES
-- WHERE OWNER_SID != 0X01;
