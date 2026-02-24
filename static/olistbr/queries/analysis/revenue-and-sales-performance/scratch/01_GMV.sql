USE olist_stg

-- ==================================================
-- find GMV over any period

-- [)
DECLARE @start_date DATETIME2 = '2018-01-01'
DECLARE @end_date DATETIME2 = '2019-01-01'

-- orders
SELECT o.*
INTO #orders_in_period
FROM sales.fact_orders AS o
WHERE o.order_approved_at >= @start_date
    AND o.order_approved_at < @end_date
ORDER BY o.order_approved_at ASC

SELECT *
FROM #orders_in_period

-- order items
SELECT oi.*
INTO #order_items_in_period
FROM sales.fact_order_items AS oi
RIGHT JOIN #orders_in_period AS oip
    ON oi.order_id = oip.order_id

SELECT SUM(oip.price) AS gmv
FROM #order_items_in_period AS oip

-- ending
DROP TABLE #orders_in_period
DROP TABLE #order_items_in_period

-- ==================================================

SELECT o.*
FROM sales.fact_orders AS o
WHERE o.order_approved_at IS NOT NULL
ORDER BY
    o.order_approved_at

-- order approved at null analysis
SELECT DISTINCT sub.order_status
FROM (
    SELECT
        -- o.*,
        -- oi.*,
        o.order_id,
        oi.order_item_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        oi.product_id,
        oi.shipping_limit_date,
        oi.price,
        oi.freight_value
    FROM sales.fact_orders AS o
    LEFT JOIN sales.fact_order_items AS oi
        ON o.order_id = oi.order_id
    -- where o.order_approved_at is null
    WHERE oi.price IS NOT NULL
) AS sub
-- order by sub.order_purchase_timestamp

-- generate order sales table
SELECT
    d.full_date,
    d.year_number,
    d.quarter_number,
    d.month_number,
    d.month_name_short,
    d.week_number,
    d.day_of_year,
    d.day_of_month,
    d.day_of_week,
    d.day_name,
    sub.price AS order_price,
    sub.freight_value AS order_freight_value
INTO #order_sales
FROM (
    SELECT
        -- o.*,
        -- oi.*,
        o.order_approved_at,
        CAST(DATETRUNC(DAY, o.order_approved_at) AS DATE) AS full_date,
        oi.price,
        oi.freight_value
    FROM sales.fact_orders AS o
    LEFT JOIN sales.fact_order_items AS oi
        ON o.order_id = oi.order_id
    WHERE oi.price IS NOT NULL
        AND o.order_status IN (
            'approved',
            'delivered',
            'invoiced',
            'processing',
            'shipped'
        )
    -- order by o.order_approved_at
) AS sub
RIGHT JOIN utils.dim_date AS d
    ON sub.full_date = d.full_date
ORDER BY d.full_date;

SELECT * FROM #order_sales

SELECT * FROM utils.dim_date

DROP TABLE #order_sales

-- GMV year
SELECT
    os.year_number,
    SUM(os.order_price)
FROM #order_sales AS os
GROUP BY os.year_number
ORDER BY os.year_number ASC

-- GMV quarter
SELECT
    os.year_number,
    os.quarter_number,
    SUM(os.order_price)
FROM #order_sales AS os
GROUP BY os.year_number, os.quarter_number
ORDER BY os.year_number ASC, os.quarter_number ASC

-- GMV month
SELECT
    os.year_number,
    os.month_number,
    SUM(os.order_price) AS gmv_month
FROM #order_sales AS os
GROUP BY os.year_number, os.month_number
ORDER BY os.year_number ASC, os.month_number ASC

-- GMV week
SELECT
    os.year_number,
    os.week_number,
    SUM(os.order_price) AS gmv_week
FROM #order_sales AS os
GROUP BY os.year_number, os.week_number
ORDER BY os.year_number ASC, os.week_number ASC

-- GMV day
SELECT
    os.full_date,
    SUM(os.order_price)
FROM #order_sales AS os
GROUP BY os.full_date
ORDER BY os.full_date ASC


SELECT * FROM utils.dim_date

/*

-- products
select distinct
    p.*
from sales.dim_products as p
right join #order_items_in_period as oiip
    on p.product_id = oiip.product_id

-- order payments
select
    op.*
from sales.fact_order_payments as op
right join #orders_in_period as oip
    on op.order_id = oip.order_id

*/
