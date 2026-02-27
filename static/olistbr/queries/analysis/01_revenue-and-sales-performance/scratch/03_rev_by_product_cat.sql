/*
revenue by product category
*/
USE olist_stg;

SELECT * FROM INFORMATION_SCHEMA.tables

-- list tables to be used
SELECT o.*
FROM sales.fact_orders AS o

SELECT oi.*
FROM sales.fact_order_items AS oi

SELECT p.*
FROM sales.dim_products AS p

SELECT pt.*
FROM sales.dim_product_category_name_translation AS pt

-- start
SELECT
    d.*,
    sub.*
INTO #order_category_revenue
FROM (
    SELECT
        -- o.*,
        -- oi.*,
        -- p.*,
        -- pt.*
        o.order_id,
        o.order_approved_at,
        CAST(o.order_approved_at AS DATE) AS order_purchase_date,
        pt.product_category_name_english,
        oi.price,
        oi.freight_value
    FROM sales.fact_orders AS o
    LEFT JOIN sales.fact_order_items AS oi
        ON o.order_id = oi.order_id
    LEFT JOIN sales.dim_products AS p
        ON oi.product_id = p.product_id
    LEFT JOIN sales.dim_product_category_name_translation AS pt
        ON p.product_category_name = pt.product_category_name
    WHERE o.order_status IN (
            'approved',
            'delivered',
            'invoiced',
            'processing',
            'shipped'
        )
        AND oi.price IS NOT NULL
) AS sub
RIGHT JOIN utils.dim_date AS d
    ON sub.order_purchase_date = d.full_date
ORDER BY d.full_date ASC, sub.product_category_name_english

/*
drop table #order_category_revenue
*/

SELECT * FROM #order_category_revenue


-- year
SELECT
    sub.*,
    sub.total_product_revenue + sub.total_freight_revenue AS total_revenue,
    sub.total_product_revenue / sub.order_count AS aov,
    sub.total_freight_revenue / sub.order_count AS avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
FROM (
    SELECT
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.product_category_name_english,
        COUNT(DISTINCT c.order_id) AS order_count,
        SUM(c.price) AS total_product_revenue,
        SUM(c.freight_value) AS total_freight_revenue
    FROM #order_category_revenue AS c
    GROUP BY c.year_number, c.product_category_name_english
) AS sub
ORDER BY sub.year_number, sub.product_category_name_english


-- quarter
SELECT
    sub.*,
    sub.total_product_revenue + sub.total_freight_revenue AS total_revenue,
    sub.total_product_revenue / sub.order_count AS aov,
    sub.total_freight_revenue / sub.order_count AS avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
FROM (
    SELECT
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.quarter_number,
        c.product_category_name_english,
        COUNT(DISTINCT c.order_id) AS order_count,
        SUM(c.price) AS total_product_revenue,
        SUM(c.freight_value) AS total_freight_revenue
    FROM #order_category_revenue AS c
    GROUP BY c.year_number, c.quarter_number, c.product_category_name_english
) AS sub
ORDER BY sub.year_number, sub.quarter_number, sub.product_category_name_english


-- month
SELECT
    sub.*,
    sub.total_product_revenue + sub.total_freight_revenue AS total_revenue,
    sub.total_product_revenue / sub.order_count AS aov,
    sub.total_freight_revenue / sub.order_count AS avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
FROM (
    SELECT
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.month_number,
        c.product_category_name_english,
        COUNT(DISTINCT c.order_id) AS order_count,
        SUM(c.price) AS total_product_revenue,
        SUM(c.freight_value) AS total_freight_revenue
    FROM #order_category_revenue AS c
    GROUP BY c.year_number, c.month_number, c.product_category_name_english
) AS sub
ORDER BY sub.year_number, sub.month_number, sub.product_category_name_english


-- week
SELECT
    sub.*,
    sub.total_product_revenue + sub.total_freight_revenue AS total_revenue,
    sub.total_product_revenue / sub.order_count AS aov,
    sub.total_freight_revenue / sub.order_count AS avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
FROM (
    SELECT
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.week_number,
        c.product_category_name_english,
        COUNT(DISTINCT c.order_id) AS order_count,
        SUM(c.price) AS total_product_revenue,
        SUM(c.freight_value) AS total_freight_revenue
    FROM #order_category_revenue AS c
    GROUP BY c.year_number, c.week_number, c.product_category_name_english
) AS sub
ORDER BY sub.year_number, sub.week_number, sub.product_category_name_english


-- day
SELECT
    sub.*,
    sub.total_product_revenue + sub.total_freight_revenue AS total_revenue,
    sub.total_product_revenue / sub.order_count AS aov,
    sub.total_freight_revenue / sub.order_count AS avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
FROM (
    SELECT
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.day_of_year,
        c.product_category_name_english,
        COUNT(DISTINCT c.order_id) AS order_count,
        SUM(c.price) AS total_product_revenue,
        SUM(c.freight_value) AS total_freight_revenue
    FROM #order_category_revenue AS c
    GROUP BY c.year_number, c.day_of_year, c.product_category_name_english
) AS sub
ORDER BY sub.year_number, sub.day_of_year, sub.product_category_name_english


-- ==================================================
-- special interest: 'health_beauty'
-- can work with no filter,
-- evolution of previous query, includes non orders on all dates
-- ==================================================

DECLARE @category VARCHAR(30) = 'health_beauty'


-- quarter
SELECT
    d.*,
    sub.product_category_name_english,
    sub.order_count,
    sub.total_product_revenue,
    sub.total_product_revenue + sub.total_freight_revenue AS total_revenue,
    sub.total_product_revenue / sub.order_count AS aov,
    sub.total_freight_revenue / sub.order_count AS avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
FROM (
    SELECT
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.quarter_number,
        c.product_category_name_english,
        COUNT(DISTINCT c.order_id) AS order_count,
        SUM(c.price) AS total_product_revenue,
        SUM(c.freight_value) AS total_freight_revenue
    FROM #order_category_revenue AS c
    WHERE c.product_category_name_english = 'health_beauty'
    GROUP BY c.year_number, c.quarter_number, c.product_category_name_english
) AS sub
RIGHT JOIN (
    SELECT
        -- d.*
        d.year_number,
        d.quarter_number
    FROM utils.dim_date AS d
    GROUP BY d.year_number, d.quarter_number
    -- order by d.year_number, d.quarter_number
) AS d
    ON sub.year_number = d.year_number
    AND sub.quarter_number = d.quarter_number
-- where sub.product_category_name_english = 'health_beauty'
ORDER BY d.year_number, d.quarter_number, sub.product_category_name_english


-- filter case, month
-- messy, includes null category
SELECT
    -- c.*,
    d.*,
    -- c.year_number,
    -- c.quarter_number,
    c.product_category_name_english,
    COUNT(DISTINCT c.order_id) AS order_count,
    SUM(c.price) AS total_product_revenue,
    SUM(c.freight_value) AS total_freight_revenue
FROM #order_category_revenue AS c
RIGHT JOIN (
    SELECT
        d.year_number,
        d.month_number,
        d.month_name
    FROM utils.dim_date AS d
    GROUP BY d.year_number, d.month_number, d.month_name
) AS d
    ON c.year_number = d.year_number
    AND c.month_number = d.month_number
WHERE c.product_category_name_english = 'health_beauty'
    OR c.product_category_name_english IS NULL
GROUP BY
    d.year_number, d.month_number, d.month_name, c.product_category_name_english
ORDER BY
    d.year_number, d.month_number, d.month_name, c.product_category_name_english


-- filter case, month repeat of quarter query
-- good
SELECT
    d.*,
    sub.product_category_name_english,
    sub.order_count,
    sub.total_product_revenue,
    sub.total_product_revenue + sub.total_freight_revenue AS total_revenue,
    sub.total_product_revenue / sub.order_count AS aov,
    sub.total_freight_revenue / sub.order_count AS avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
FROM (
    SELECT
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.month_number,
        c.product_category_name_english,
        COUNT(DISTINCT c.order_id) AS order_count,
        SUM(c.price) AS total_product_revenue,
        SUM(c.freight_value) AS total_freight_revenue
    FROM #order_category_revenue AS c
    WHERE c.product_category_name_english = 'health_beauty'
    GROUP BY c.year_number, c.month_number, c.product_category_name_english
) AS sub
RIGHT JOIN (
    SELECT
        -- d.*
        d.year_number,
        d.month_number
    FROM utils.dim_date AS d
    GROUP BY d.year_number, d.month_number
    -- order by d.year_number, d.month_number
) AS d
    ON sub.year_number = d.year_number
    AND sub.month_number = d.month_number
-- where sub.product_category_name_english = 'health_beauty'
ORDER BY d.year_number, d.month_number, sub.product_category_name_english


-- week
SELECT
    d.*,
    sub.product_category_name_english,
    sub.order_count,
    sub.total_product_revenue,
    sub.total_product_revenue + sub.total_freight_revenue AS total_revenue,
    sub.total_product_revenue / sub.order_count AS aov,
    sub.total_freight_revenue / sub.order_count AS avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
FROM (
    SELECT
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.week_number,
        c.product_category_name_english,
        COUNT(DISTINCT c.order_id) AS order_count,
        SUM(c.price) AS total_product_revenue,
        SUM(c.freight_value) AS total_freight_revenue
    FROM #order_category_revenue AS c
    WHERE c.product_category_name_english = 'health_beauty'
    GROUP BY c.year_number, c.week_number, c.product_category_name_english
) AS sub
RIGHT JOIN (
    SELECT
        -- d.*
        d.year_number,
        d.week_number
    FROM utils.dim_date AS d
    GROUP BY d.year_number, d.week_number
    -- order by d.year_number, d.week_number
) AS d
    ON sub.year_number = d.year_number
    AND sub.week_number = d.week_number
-- where sub.product_category_name_english = 'health_beauty'
ORDER BY d.year_number, d.week_number, sub.product_category_name_english


-- day
SELECT
    d.*,
    sub.product_category_name_english,
    sub.order_count,
    sub.total_product_revenue,
    sub.total_product_revenue + sub.total_freight_revenue AS total_revenue,
    sub.total_product_revenue / sub.order_count AS aov,
    sub.total_freight_revenue / sub.order_count AS avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
FROM (
    SELECT
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.day_of_year,
        c.product_category_name_english,
        COUNT(DISTINCT c.order_id) AS order_count,
        SUM(c.price) AS total_product_revenue,
        SUM(c.freight_value) AS total_freight_revenue
    FROM #order_category_revenue AS c
    WHERE c.product_category_name_english = 'health_beauty'
    GROUP BY c.year_number, c.day_of_year, c.product_category_name_english
) AS sub
RIGHT JOIN (
    SELECT
        -- d.*
        d.year_number,
        d.day_of_year
    FROM utils.dim_date AS d
    GROUP BY d.year_number, d.day_of_year
    -- order by d.year_number, d.day_of_year
) AS d
    ON sub.year_number = d.year_number
    AND sub.day_of_year = d.day_of_year
-- where sub.product_category_name_english = 'health_beauty'
ORDER BY d.year_number, d.day_of_year, sub.product_category_name_english
