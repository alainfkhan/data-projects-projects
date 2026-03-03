USE olist_stg;

-- ==================================================
-- total revenues (per state) of orders made by users who have ordered before
-- ==================================================

WITH user_recent_orders AS (
    -- the most recent order of each user
    SELECT
        o.order_purchase_timestamp,
        CAST(o.order_purchase_timestamp AS DATE) AS order_purchase_date,
        o.customer_id,
        c.customer_unique_id,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY
                o.order_purchase_timestamp DESC
        ) AS rn
    FROM sales.fact_orders AS o
        LEFT JOIN sales.dim_customers AS c
            ON o.customer_id = c.customer_id
),

user_last_orders AS (
    -- the last order of each user (total rows = 96096)
    SELECT ro.*
    FROM user_recent_orders AS ro
    WHERE ro.rn = 1
),

user_not_last_orders AS (
    -- the orders that aren't the last
    -- can imply get users who have ordered before
    SELECT ro.*
    FROM user_recent_orders AS ro
    WHERE ro.rn > 1
)
-- select ro.*
-- from user_not_last_orders as ro
-- select lo.*
-- from user_last_orders as lo

SELECT
    s.year_number,
    s.month_number,
    ufs.uf,
    COUNT(DISTINCT s.order_id) AS order_count,
    SUM(s.price) AS total_product_revenue,
    SUM(s.freight_value) AS total_freight_revenue,
    SUM(s.price + s.freight_value) AS total_revenue
FROM sales.vw_sales AS s
    LEFT JOIN sales.dim_customers AS c
        ON s.customer_id = c.customer_id
    LEFT JOIN (
        -- all ufs
        SELECT DISTINCT LEFT(cep.uf, 2) AS uf
        FROM logistics.dim_cep AS cep
    ) AS ufs
        ON c.customer_state = ufs.uf
WHERE c.customer_unique_id IN (
    -- users who have ordered before
    SELECT DISTINCT nlo.customer_unique_id
    FROM user_not_last_orders AS nlo
)
GROUP BY
    s.year_number,
    s.month_number,
    ufs.uf
ORDER BY
    s.year_number,
    s.month_number,
    ufs.uf

-- ==================================================

-- explanation
/*
total revenues (per state) of orders made by users who have ordered before

there is one order where it isnt categorised in a defined date
*/

SELECT
    oi.*,
    o.*,
    c.*
FROM sales.fact_order_items AS oi
    LEFT JOIN sales.fact_orders AS o
        ON oi.order_id = o.order_id
    LEFT JOIN sales.dim_customers AS c
        ON o.customer_id = c.customer_id
WHERE oi.price = '149.8000'
    AND oi.freight_value = '13.6300'

/*
order_id, order_purchase_timestamp, order_approved_at
7f13a20e25350f4a55fb2a7c9a2e8d88 2017-03-13 18:14:37.0000000	2017-03-13 18:14:37.0000000
d69e5d356402adc8cf17e08b5033acfb 2017-02-19 01:28:47.0000000	NULL

customer_unique_id
51838d41add414a0b1b989b7d251d9ee
2e0a2166aa23da2472c6a60c4af6f7a6

product_id
cae2e38942c8489d9d7a87a3f525c06b

seller_id
cca3071e3e9bb7d12640c9fbe2301306
*/

SELECT
    o.*,
    oi.*,
    c.*
FROM sales.fact_orders AS o
    LEFT JOIN sales.fact_order_items AS oi
        ON o.order_id = oi.order_id
    LEFT JOIN sales.dim_customers AS c
        ON o.customer_id = c.customer_id
WHERE c.customer_unique_id IN (
    '51838d41add414a0b1b989b7d251d9ee',
    '2e0a2166aa23da2472c6a60c4af6f7a6'
)

-- find product
SELECT
    p.*,
    pt.*
FROM sales.dim_products AS p
    LEFT JOIN sales.dim_product_category_name_translation AS pt
        ON p.product_category_name = pt.product_category_name
WHERE p.product_id = 'cae2e38942c8489d9d7a87a3f525c06b'

-- find seller
SELECT s.*
FROM sales.dim_sellers AS s
WHERE s.seller_id = 'cca3071e3e9bb7d12640c9fbe2301306'


SELECT o.*
FROM sales.fact_orders AS o
WHERE CAST(o.order_purchase_timestamp AS DATE) = '2017-02-19'
ORDER BY o.order_purchase_timestamp

SELECT o.*
FROM sales.fact_orders AS o
WHERE o.order_approved_at IS NULL


-- scratch

WITH cte AS (
    SELECT
        -- o.*,
        -- oi.*
        o.order_purchase_timestamp,
        CAST(o.order_purchase_timestamp AS DATE) AS order_purchase_date,
        o.order_approved_at,
        CAST(order_approved_at AS DATE) AS order_approved_date,
        CASE
            WHEN
                (
                    CAST(o.order_purchase_timestamp AS DATE)
                    = CAST(o.order_approved_at AS DATE)
                )
            THEN 1
            ELSE 0
        END AS is_same_date
    FROM sales.fact_orders AS o
        LEFT JOIN sales.fact_order_items AS oi
            ON o.order_id = oi.order_id
),

purchased_dates AS (
    SELECT DISTINCT cte.order_purchase_date
    FROM cte
),

approved_dates AS (
    SELECT DISTINCT cte.order_approved_date
    FROM cte
)

SELECT
    d.full_date,
    pd.*,
    ad.*
FROM utils.dim_date AS d
    LEFT JOIN purchased_dates AS pd
        ON d.key_date = pd.order_purchase_date
    LEFT JOIN approved_dates AS ad
        ON d.key_date = ad.order_approved_date
ORDER BY d.full_date


/*
a repeat user is someone who has made more than one order
*/
-- first attempt
GO;
-- ==================================================

WITH relu AS (
    -- relocated users
    SELECT DISTINCT c.customer_unique_id AS relocated_users        -- c.*

    FROM (
        SELECT
            c.customer_unique_id,
            c.customer_zip_code_prefix,
            c.customer_city,
            c.customer_state,
            ROW_NUMBER() OVER (
                PARTITION BY c.customer_unique_id
                ORDER BY
                    c.customer_unique_id,
                    c.customer_zip_code_prefix,
                    c.customer_city,
                    c.customer_state
            ) AS rn
        FROM sales.dim_customers AS c
        GROUP BY
            c.customer_unique_id,
            c.customer_zip_code_prefix,
            c.customer_city,
            c.customer_state
    ) AS c
    WHERE c.rn > 1
    -- order by relocated_users
    -- order by
    --     c.customer_unique_id,
    --     c.customer_zip_code_prefix,
    --     c.customer_city,
    --     c.customer_state
)

SELECT
    o.order_purchase_timestamp,
    o.customer_id,
    relu.relocated_users,
    ROW_NUMBER() OVER (
        PARTITION BY relu.relocated_users
        ORDER BY o.order_purchase_timestamp DESC
    ) AS rn
FROM sales.fact_orders AS o
    LEFT JOIN sales.dim_customers AS c
        ON o.customer_id = c.customer_id
    RIGHT JOIN relu
        ON c.customer_unique_id = relu.relocated_users

-- ...

GO;
-- ==================================================


-- this user has had 3 relocations
-- d44ccec15f5f86d14d6a2cfa67da1975
SELECT c.*
FROM sales.dim_customers AS c
WHERE c.customer_unique_id = '83e7958a94bd7f74a9414d8782f87628'
