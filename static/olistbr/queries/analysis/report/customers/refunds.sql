USE olist;
GO

-- want to find eligable refund orders

WITH sale_order_ids AS (
    -- order_ids that are sales
    SELECT DISTINCT s.order_id
    FROM sales.vw_sales_practical AS s
    WHERE s.order_id IS NOT NULL
),

non_sale_payments AS (
    /*
    orders
        that are not sales
        that have payments
    */
    SELECT op.*
        -- soids.*
    FROM sales.fact_order_payments AS op
        LEFT JOIN sale_order_ids AS soids
            ON op.order_id = soids.order_id
    WHERE soids.order_id IS NULL
)

SELECT nsp.*
FROM non_sale_payments AS nsp
ORDER BY nsp.order_id ASC

-- total recorded revenue
SELECT
    SUM(o.price) AS order_price,
    SUM(o.freight_value) AS order_freight,
    SUM(o.price + o.freight_value) AS order_price_freight
FROM sales.vw_orders AS o
/*
order_price, order_freight, order_price_freight
13591643.7000, 2251909.5400, 15843553.2400
*/

-- total sale revenue
SELECT
    SUM(s.price) AS sales_price,
    SUM(s.freight_value) AS sales_freight,
    SUM(s.price + s.freight_value) AS sales_price_freight
FROM sales.vw_sales AS s
/*
sales_price, sales_freight, sales_price_freight
13492730.3100, 2240842.1200, 15733572.4300

difference
*/
