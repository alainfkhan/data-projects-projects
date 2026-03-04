USE olist;
GO

-- ==================================================
-- prerequisite table join
CREATE OR ALTER VIEW sales.vw_join_orders AS
SELECT
    o.order_id,
    oi.order_item_id,
    oi.product_id,
    o.customer_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    oi.shipping_limit_date,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    CAST(o.order_estimated_delivery_date AS DATE)
        AS order_estimated_delivery_date
FROM sales.fact_orders AS o
    LEFT JOIN sales.fact_order_items AS oi
        ON o.order_id = oi.order_id;
GO

-- ==================================================
-- orders
CREATE OR ALTER VIEW sales.vw_orders AS
SELECT
    d.*,
    o.*
FROM sales.vw_join_orders AS o
    RIGHT JOIN utils.dim_date AS d
        -- an order occurs at purchase date
        ON CAST(o.order_purchase_timestamp AS DATE) = d.key_date;
GO

-- ==================================================
-- sales
CREATE OR ALTER VIEW sales.vw_sales AS
WITH cte_sales AS (
    SELECT o.*
    FROM sales.vw_join_orders AS o
    WHERE
        -- a sale occurs when:
        o.order_status IN (
            'approved',
            'delivered',
            'invoiced',
            'processing',
            'shipped'
        )
        -- a sale is measurable when:
        AND o.price IS NOT NULL
)

SELECT
    d.*,
    s.*
FROM cte_sales AS s
    RIGHT JOIN utils.dim_date AS d
        -- a realised and measurable sale occurs at approved date
        ON CAST(s.order_approved_at AS DATE) = d.key_date;
GO

-- ==================================================
-- practical dates
DECLARE @practical_start_date DATE = '2017-01-08';
DECLARE @practical_end_date DATE = '2018-08-21';
GO

-- ==================================================
-- orders practical dates
CREATE OR ALTER VIEW sales.vw_orders_practical AS
SELECT s.*
FROM sales.vw_orders AS s
WHERE s.full_date BETWEEN '2017-01-08' AND '2018-08-21';
GO

-- ==================================================
-- sales practical dates
CREATE OR ALTER VIEW sales.vw_sales_practical AS
SELECT s.*
FROM sales.vw_sales AS s
WHERE s.full_date BETWEEN '2017-01-08' AND '2018-08-21';
GO
