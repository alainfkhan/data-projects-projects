USE olist_stg;

/*
-- scratchwork
select top 1000
    o.*
from sales.fact_orders as o;

-- highest order_item_id
select
    sub.order_id,
    sub.order_item_id,
    sub.product_id,
    sub.seller_id,
    sub.shipping_limit_date,
    sub.price,
    sub.freight_value
from (
    select top 1000
        ot.*,
        row_number() over (
            partition by ot.order_id
            order by ot.order_item_id desc
        ) as row_number
    from sales.fact_order_items as ot
    where ot.order_item_id > 1
    order by ot.order_item_id desc
) as sub
where sub.row_number = 1

select
    ot.*
from sales.fact_order_items as ot
where ot.order_id = '8272b63d03f5f79c56e9e4120aec44ef'
*/

-- =========================================
-- Choose initial values
-- =========================================

-- choose any order_id
DECLARE @order_id CHAR(32)
-- choose random
-- set @order_id = '00010242fe8c5a6d1ba2dd792cb16214'
-- set @order_id = '0010dedd556712d7bb69a19cb7bbd37a'
-- set @order_id = '000e906b789b55f64edcb1f84030f90d'
-- set @order_id = '0009c9a17f916a706d71784483a5d643'


-- most order_item_id = 21
-- set @order_id = '8272b63d03f5f79c56e9e4120aec44ef'
-- order_item_id max = 20
-- set @order_id = 'ab14fdcfbe524636d65ee38360e22ce8'
-- order_item_id max = 9
-- set @order_id = 'f5aa338a071dcf7d23d8e6b116bfcab5'
-- order_item_id max = 7
-- set @order_id = '7d316b369d4c6b0a4ebeebbff5f65466'
-- order_item_id max = 5, 4 product_ids
SET @order_id = 'cb8a63e70a7f664281f701b6abd79fe5'

-- if multiple product_ids choose which
DECLARE @choose_product_id TINYINT = 1

-- =========================================
-- =========================================


-- orders
SELECT TOP 1000 o.*
FROM sales.fact_orders AS o
WHERE o.order_id = @order_id

-- customers
DECLARE @customer_id CHAR(32) = (
    SELECT o.customer_id
    FROM sales.fact_orders AS o
    WHERE o.order_id = @order_id
)

SELECT c.*
FROM sales.dim_customers AS c
WHERE c.customer_id = @customer_id


-- order_items
SELECT TOP 1000 ot.*
FROM sales.fact_order_items AS ot
WHERE ot.order_id = @order_id

-- get unique product_ids 
SELECT DISTINCT sub.product_id AS product_ids
FROM (
    SELECT TOP 1000 ot.*
    FROM sales.fact_order_items AS ot
    WHERE ot.order_id = @order_id
) AS sub

DECLARE @product_id CHAR(32)
-- choose row for 1 product id. default 1
SET @product_id = (

    SELECT choose.product_id
    FROM (

        SELECT
            distinct_product_ids.product_id,
            ROW_NUMBER() OVER (
                ORDER BY distinct_product_ids.product_id
            ) AS choose_row
        FROM (
            SELECT DISTINCT repeat_orders.product_id
            FROM (
                SELECT TOP 1000 oi.*
                FROM sales.fact_order_items AS oi
                WHERE oi.order_id = @order_id
                -- where oi.order_id = '8272b63d03f5f79c56e9e4120aec44ef'
            ) AS repeat_orders
        ) AS distinct_product_ids

    ) AS choose
    WHERE choose.choose_row = @choose_product_id

)

/*
-- if one product_id
set @product_id = (
    select top 1000
        ot.product_id
    from sales.fact_order_items as ot
    where ot.order_id = @order_id
)
*/

-- order_payments
SELECT TOP 1000 op.*
FROM sales.fact_order_payments AS op
WHERE op.order_id = @order_id

-- products
SELECT TOP 1000 p.*
FROM sales.dim_products AS p
WHERE p.product_id = @product_id

DECLARE @product_category_name VARCHAR(50)
SET @product_category_name = (
    SELECT TOP 1000 p.product_category_name
    FROM sales.dim_products AS p
    WHERE p.product_id = @product_id
)

PRINT @product_category_name

-- translation
SELECT t.product_category_name_english
FROM sales.dim_product_category_name_translation AS t
WHERE t.product_category_name = @product_category_name
-- where t.product_category_name = 'automotivo'
-- where t.product_category_name = 'beleza_saude'
