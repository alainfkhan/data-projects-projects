USE olist_stg;
-- ==================================================
-- which sellers generate the most revenue?
-- ==================================================

SELECT o.*
FROM sales.fact_orders AS o

SELECT oi.*
FROM sales.fact_order_items AS oi

SELECT s.*
FROM sales.dim_sellers AS s

-- lifetime top sellers by product revenue
/*
seller_id, total_product_revenue
4869f7a5dfa277a7dca6462dcf3b52b2, 229237.6300
53243585a1d6dc2643021fd1853d8905, 222776.0500
4a3ca9315b744ce9f8e9374361493884, 200326.1200
fa1c13f2614d7b5c4749cbc52fecda94, 192842.1300
7c67e1448b00f6e969d365cea6b010ab, 187923.8900
7e93a43ef30c4f03f38b393420bc753a, 172583.8800
da8622b14eb17ae2831f4ac5b9dab84a, 160236.5700
7a67c85e85bb2ce8582c35f2203ad736, 141715.5400
1025f0e2d44d7041d6cf58b6550e0bfa, 138968.5500
955fee9216a65b617aa5c0531780ce60, 135159.7000
*/
SELECT TOP 10
    -- o.*,
    -- oi.*,
    -- s.*
    -- o.order_id,
    -- o.order_approved_at,
    -- cast(o.order_approved_at as date) as order_approved_date,
    -- oi.seller_id,
    -- oi.price,
    -- oi.freight_value
    oi.seller_id,
    COUNT(DISTINCT o.order_id) order_count,
    SUM(oi.price) AS total_product_revenue,
    SUM(oi.freight_value) AS total_freight_revenue
FROM sales.fact_orders AS o
LEFT JOIN sales.fact_order_items AS oi
    ON o.order_id = oi.order_id
LEFT JOIN sales.dim_sellers AS s
    ON oi.seller_id = s.seller_id
WHERE o.order_status IN (
    'approved',
    'delivered',
    'invoiced',
    'processing',
    'shipped'
    )
    AND oi.price IS NOT NULL
GROUP BY oi.seller_id
ORDER BY SUM(oi.price) DESC

-- 3095 distinct sellers
SELECT COUNT(DISTINCT seller_id)
FROM sales.fact_order_items AS oi

SELECT COUNT(*)
FROM sales.fact_order_items AS oi


-- ==================================================
-- functional query to change grain
/*
three points to uncomment
    select, group by, order by

group by values = order by values => <g/o>
select values = <g/o> values, sub.seller_id

choose grain
year:
    select d.year_number
    <g/o> by d.year_number, sub.seller_id
quarter:
    select d.year_number, d.quarter_number
    <g/o> by d.year_number, d.quarter_number, sub.seller_id
month:
    select d.year_number, d.month_number
    <g/o> by d.year_number, d.month_number, sub.seller_id
week:
    select d.year_number, d.week_number
    <g/o> by d.year_number, d.week_number, sub.seller_id
day:
    select d.year_number, d.full_date
    <g/o> by d.year_number, d.full_date, sub.seller_id

feel free to choose options in where sub.seller_id in ()

*/
-- ==================================================

SELECT

    -- year (always)
    d.year_number,
    -- -- quarter
    -- d.quarter_number,
    -- -- month
    -- d.month_number,
    -- -- week
    -- d.week_number,
    -- day
    d.full_date,

    sub.seller_id,
    SUM(sub.order_count) AS total_order_count,
    SUM(sub.total_product_revenue) AS total_product_revenue,
    SUM(sub.total_freight_revenue) AS total_freight_revenue
FROM (
    SELECT
        CAST(o.order_approved_at AS DATE) AS order_approved_date,
        oi.seller_id,
        COUNT(DISTINCT o.order_id) order_count,
        SUM(oi.price) AS total_product_revenue,
        SUM(oi.freight_value) AS total_freight_revenue
    FROM sales.fact_orders AS o
    LEFT JOIN sales.fact_order_items AS oi
        ON o.order_id = oi.order_id
    LEFT JOIN sales.dim_sellers AS s
        ON oi.seller_id = s.seller_id
    WHERE o.order_status IN (
        'approved',
        'delivered',
        'invoiced',
        'processing',
        'shipped'
        )
        AND oi.price IS NOT NULL
    GROUP BY CAST(o.order_approved_at AS DATE), oi.seller_id
) AS sub
RIGHT JOIN utils.dim_date AS d
    ON sub.order_approved_date = d.full_date
WHERE sub.seller_id IN (
    '4869f7a5dfa277a7dca6462dcf3b52b2'
    -- '53243585a1d6dc2643021fd1853d8905',
    -- '4a3ca9315b744ce9f8e9374361493884',
    -- 'fa1c13f2614d7b5c4749cbc52fecda94',
    -- '7c67e1448b00f6e969d365cea6b010ab',
    -- '7e93a43ef30c4f03f38b393420bc753a',
    -- 'da8622b14eb17ae2831f4ac5b9dab84a',
    -- '7a67c85e85bb2ce8582c35f2203ad736',
    -- '1025f0e2d44d7041d6cf58b6550e0bfa',
    -- '955fee9216a65b617aa5c0531780ce60'
    )
GROUP BY
    d.year_number,
    -- d.quarter_number,
    -- d.month_number, 
    -- d.week_number,
    d.full_date,
    sub.seller_id
ORDER BY
    d.year_number,
    -- d.quarter_number,
    -- d.month_number,
    -- d.week_number,
    d.full_date,
    sub.seller_id
