/*
revenue by state
    for customers
    for sellers

definitions:
sale if
    order_status:
        'approved',
        'delivered',
        'invoiced',
        'processing',
        'shipped'
    price not null

accounting sale made at order_approved_at

*/
USE olist_stg;

-- list tables
SELECT o.*
FROM sales.fact_orders AS o

SELECT oi.*
FROM sales.fact_order_items AS oi

SELECT c.*
FROM sales.dim_customers AS c

SELECT s.*
FROM sales.dim_sellers AS s

SELECT TOP 1000 g.*
FROM logistics.fact_geolocation AS g

SELECT TOP 1000 cep.*
FROM logistics.dim_cep AS cep

-- joins
SELECT
    -- o.*,
    -- c.*,
    -- oi.*,
    -- s.*,
    d.*,
    o.order_id,
    o.order_approved_at,
    CAST(o.order_approved_at AS DATE) AS order_approved_date,
    oi.price,
    oi.freight_value,
    c.customer_state,
    s.seller_state
INTO #orders_cs_state   -- cs means customer seller
FROM sales.fact_orders AS o
    LEFT JOIN sales.dim_customers AS c
        ON o.customer_id = c.customer_id
    LEFT JOIN sales.fact_order_items AS oi
        ON o.order_id = oi.order_id
    LEFT JOIN sales.dim_sellers AS s
        ON oi.seller_id = s.seller_id
    RIGHT JOIN utils.dim_date AS d
        ON CAST(o.order_approved_at AS DATE) = d.full_date
WHERE o.order_status IN (
    'approved',
    'delivered',
    'invoiced',
    'processing',
    'shipped')
    AND oi.price IS NOT NULL
ORDER BY o.order_approved_at

DROP TABLE #orders_cs_state

SELECT o.*
FROM #orders_cs_state AS o
ORDER BY o.order_approved_at

-- start
-- whole dataset
-- customer
SELECT
    o.customer_state,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.price) AS total_product_revenue,
    SUM(o.freight_value) AS total_freight_revenue
FROM #orders_cs_state AS o
GROUP BY o.customer_state
ORDER BY o.customer_state

-- seller
SELECT
    o.seller_state,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.price) AS total_product_revenue,
    SUM(o.freight_value) AS total_freight_revenue
FROM #orders_cs_state AS o
GROUP BY o.seller_state
ORDER BY o.seller_state

-- all together
SELECT
    -- cep.*,
    -- c.*,
    -- s.*
    cep.br_state,
    s.seller_order_count,
    s.seller_product_gmv,
    s.seller_freight_gmv,
    c.customer_order_count,
    c.customer_product_gmv,
    c.customer_freight_gmv
FROM (
    SELECT DISTINCT LEFT(cep.uf, 2) AS br_state
    FROM logistics.dim_cep AS cep
) AS cep
    LEFT JOIN (
        SELECT
            o.customer_state,
            COUNT(DISTINCT o.order_id) AS customer_order_count,
            SUM(o.price) AS customer_product_gmv,
            SUM(o.freight_value) AS customer_freight_gmv
        FROM #orders_cs_state AS o
        GROUP BY o.customer_state
        ) AS c
        ON cep.br_state = c.customer_state
    LEFT JOIN (
        SELECT
            o.seller_state,
            COUNT(DISTINCT o.order_id) AS seller_order_count,
            SUM(o.price) AS seller_product_gmv,
            SUM(o.freight_value) AS seller_freight_gmv
        FROM #orders_cs_state AS o
        GROUP BY o.seller_state
        ) AS s
        ON cep.br_state = s.seller_state
ORDER BY cep.br_state

-- ==================================================
-- revenue by state by time
-- ==================================================

-- year
SELECT
    sub.*,
    c.customer_order_count,
    c.customer_product_gmv,
    c.customer_freight_gmv,
    s.seller_order_count,
    s.seller_product_gmv,
    s.seller_freight_gmv
FROM (
    SELECT DISTINCT
        d.year_number,
        cep.br_state
    FROM utils.dim_date AS d
        CROSS JOIN (
            SELECT DISTINCT LEFT(cep.uf, 2) AS br_state
            FROM logistics.dim_cep AS cep
            ) AS cep
    GROUP BY d.year_number, cep.br_state
) AS sub
    LEFT JOIN (
        SELECT
            o.year_number,
            o.customer_state,
            COUNT(DISTINCT o.order_id) AS customer_order_count,
            SUM(o.price) AS customer_product_gmv,
            SUM(o.freight_value) AS customer_freight_gmv
        FROM #orders_cs_state AS o
        GROUP BY o.year_number, o.customer_state
        ) AS c
        ON sub.year_number = c.year_number
            AND sub.br_state = c.customer_state
    LEFT JOIN (
        SELECT
            o.year_number,
            o.seller_state,
            COUNT(DISTINCT o.order_id) AS seller_order_count,
            SUM(o.price) AS seller_product_gmv,
            SUM(o.freight_value) AS seller_freight_gmv
        FROM #orders_cs_state AS o
        GROUP BY o.year_number, o.seller_state
        ) AS s
        ON sub.year_number = s.year_number
            AND sub.br_state = s.seller_state
-- where sub.br_state = 'SP'
ORDER BY sub.year_number, sub.br_state

-- quarter
SELECT
    sub.*,
    c.customer_order_count,
    c.customer_product_gmv,
    c.customer_freight_gmv,
    s.seller_order_count,
    s.seller_product_gmv,
    s.seller_freight_gmv
FROM (
    SELECT DISTINCT
        d.year_number,
        d.quarter_number,
        cep.br_state
    FROM utils.dim_date AS d
        CROSS JOIN (
            SELECT DISTINCT LEFT(cep.uf, 2) AS br_state
            FROM logistics.dim_cep AS cep
            ) AS cep
    GROUP BY d.year_number, d.quarter_number, cep.br_state
) AS sub
    LEFT JOIN (
        SELECT
            o.year_number,
            o.quarter_number,
            o.customer_state,
            COUNT(DISTINCT o.order_id) AS customer_order_count,
            SUM(o.price) AS customer_product_gmv,
            SUM(o.freight_value) AS customer_freight_gmv
        FROM #orders_cs_state AS o
        GROUP BY o.year_number, o.quarter_number, o.customer_state
        ) AS c
        ON sub.year_number = c.year_number
            AND sub.quarter_number = c.quarter_number
            AND sub.br_state = c.customer_state
    LEFT JOIN (
        SELECT
            o.year_number,
            o.quarter_number,
            o.seller_state,
            COUNT(DISTINCT o.order_id) AS seller_order_count,
            SUM(o.price) AS seller_product_gmv,
            SUM(o.freight_value) AS seller_freight_gmv
        FROM #orders_cs_state AS o
        GROUP BY o.year_number, o.quarter_number, o.seller_state
        ) AS s
        ON sub.year_number = s.year_number
            AND sub.quarter_number = s.quarter_number
            AND sub.br_state = s.seller_state
-- where sub.br_state = 'SP'
ORDER BY sub.year_number, sub.quarter_number, sub.br_state


-- month
SELECT
    sub.*,
    c.customer_order_count,
    c.customer_product_gmv,
    c.customer_freight_gmv,
    s.seller_order_count,
    s.seller_product_gmv,
    s.seller_freight_gmv
FROM (
    SELECT DISTINCT
        d.year_number,
        d.month_number,
        cep.br_state
    FROM utils.dim_date AS d
        CROSS JOIN (
            SELECT DISTINCT LEFT(cep.uf, 2) AS br_state
            FROM logistics.dim_cep AS cep
            ) AS cep
    GROUP BY d.year_number, d.month_number, cep.br_state
) AS sub
    LEFT JOIN (
        SELECT
            o.year_number,
            o.month_number,
            o.customer_state,
            COUNT(DISTINCT o.order_id) AS customer_order_count,
            SUM(o.price) AS customer_product_gmv,
            SUM(o.freight_value) AS customer_freight_gmv
        FROM #orders_cs_state AS o
        GROUP BY o.year_number, o.month_number, o.customer_state
        ) AS c
        ON sub.year_number = c.year_number
            AND sub.month_number = c.month_number
            AND sub.br_state = c.customer_state
    LEFT JOIN (
        SELECT
            o.year_number,
            o.month_number,
            o.seller_state,
            COUNT(DISTINCT o.order_id) AS seller_order_count,
            SUM(o.price) AS seller_product_gmv,
            SUM(o.freight_value) AS seller_freight_gmv
        FROM #orders_cs_state AS o
        GROUP BY o.year_number, o.month_number, o.seller_state
        ) AS s
        ON sub.year_number = s.year_number
            AND sub.month_number = s.month_number
            AND sub.br_state = s.seller_state
-- where sub.br_state = 'SP'
ORDER BY sub.year_number, sub.month_number, sub.br_state

-- week
SELECT
    sub.*,
    c.customer_order_count,
    c.customer_product_gmv,
    c.customer_freight_gmv,
    s.seller_order_count,
    s.seller_product_gmv,
    s.seller_freight_gmv
FROM (
    SELECT DISTINCT
        d.year_number,
        d.week_number,
        cep.br_state
    FROM utils.dim_date AS d
        CROSS JOIN (
            SELECT DISTINCT LEFT(cep.uf, 2) AS br_state
            FROM logistics.dim_cep AS cep
            ) AS cep
    GROUP BY d.year_number, d.week_number, cep.br_state
) AS sub
    LEFT JOIN (
        SELECT
            o.year_number,
            o.week_number,
            o.customer_state,
            COUNT(DISTINCT o.order_id) AS customer_order_count,
            SUM(o.price) AS customer_product_gmv,
            SUM(o.freight_value) AS customer_freight_gmv
        FROM #orders_cs_state AS o
        GROUP BY o.year_number, o.week_number, o.customer_state
        ) AS c
        ON sub.year_number = c.year_number
            AND sub.week_number = c.week_number
            AND sub.br_state = c.customer_state
    LEFT JOIN (
        SELECT
            o.year_number,
            o.week_number,
            o.seller_state,
            COUNT(DISTINCT o.order_id) AS seller_order_count,
            SUM(o.price) AS seller_product_gmv,
            SUM(o.freight_value) AS seller_freight_gmv
        FROM #orders_cs_state AS o
        GROUP BY o.year_number, o.week_number, o.seller_state
        ) AS s
        ON sub.year_number = s.year_number
            AND sub.week_number = s.week_number
            AND sub.br_state = s.seller_state
-- where sub.br_state = 'SP'
ORDER BY sub.year_number, sub.week_number, sub.br_state

-- day
SELECT
    sub.*,
    c.customer_order_count,
    c.customer_product_gmv,
    c.customer_freight_gmv,
    s.seller_order_count,
    s.seller_product_gmv,
    s.seller_freight_gmv
FROM (
    SELECT DISTINCT
        d.year_number,
        d.day_of_year,
        cep.br_state
    FROM utils.dim_date AS d
        CROSS JOIN (
            SELECT DISTINCT LEFT(cep.uf, 2) AS br_state
            FROM logistics.dim_cep AS cep
            ) AS cep
    GROUP BY d.year_number, d.day_of_year, cep.br_state
) AS sub
    LEFT JOIN (
        SELECT
            o.year_number,
            o.day_of_year,
            o.customer_state,
            COUNT(DISTINCT o.order_id) AS customer_order_count,
            SUM(o.price) AS customer_product_gmv,
            SUM(o.freight_value) AS customer_freight_gmv
        FROM #orders_cs_state AS o
        GROUP BY o.year_number, o.day_of_year, o.customer_state
        ) AS c
        ON sub.year_number = c.year_number
            AND sub.day_of_year = c.day_of_year
            AND sub.br_state = c.customer_state
    LEFT JOIN (
        SELECT
            o.year_number,
            o.day_of_year,
            o.seller_state,
            COUNT(DISTINCT o.order_id) AS seller_order_count,
            SUM(o.price) AS seller_product_gmv,
            SUM(o.freight_value) AS seller_freight_gmv
        FROM #orders_cs_state AS o
        GROUP BY o.year_number, o.day_of_year, o.seller_state
        ) AS s
        ON sub.year_number = s.year_number
            AND sub.day_of_year = s.day_of_year
            AND sub.br_state = s.seller_state
-- where sub.br_state = 'SP'
ORDER BY sub.year_number, sub.day_of_year, sub.br_state
