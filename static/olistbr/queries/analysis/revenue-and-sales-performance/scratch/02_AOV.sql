USE olist_stg;

-- redo
-- join relevant tables, filter, aggregate revenue, join date
SELECT
    d.*,
    sub.*
INTO #order_revenue
FROM (
    SELECT
        -- o.*,
        -- oi.*
        -- cast(o.order_purchase_timestamp as date) as order_purchase_date,
        CAST(o.order_approved_at AS DATE) AS order_approved_date,
        SUM(oi.price) AS total_product_revenue,
        SUM(oi.freight_value) AS total_freight_revenue,
        COUNT(DISTINCT o.order_id) AS order_count
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
    -- group by cast(o.order_purchase_timestamp as date)
    GROUP BY CAST(o.order_approved_at AS DATE)
) AS sub
RIGHT JOIN utils.dim_date AS d
    ON sub.order_approved_date = d.full_date
ORDER BY d.date_key

/*
drop table #order_revenue
*/

-- verify distinct count
SELECT COUNT(DISTINCT o.order_id)
FROM sales.fact_orders AS o
WHERE CAST(o.order_approved_at AS DATE) = '2018-04-18'
-- 275 (correct)

-- 293 distinct sales in 2016 (correct)
-- 44304 distinct sales in 2017 (correct)
-- 53588 disintct sales in 2018 (correct)
SELECT COUNT(DISTINCT o.order_id)
    -- o.*
FROM sales.fact_orders AS o
LEFT JOIN sales.fact_order_items AS oi
    ON o.order_id = oi.order_id
WHERE DATEPART(YEAR, o.order_approved_at) = '2018'
    AND oi.price IS NOT NULL
    AND o.order_status IN (
        'approved',
        'delivered',
        'invoiced',
        'processing',
        'shipped'
    )

-- view created table
SELECT *
FROM #order_revenue AS r
ORDER BY r.date_key

-- ==================================================
-- NEW ATTEMPT
-- same result as old attempt, better intelisense
-- filter, aggregate, aggregate again at query
-- aggregation happens twice
-- smallest grain defined at table creation, less versitile
-- sufficient if smallest grain: day
-- ==================================================

-- AOV and GMV
-- GMV = total product_revenue
-- AOV = product_revenue / order_count = GMV / order_count

-- year
SELECT
    sub.*,
    sub.year_product_revenue + sub.year_freight_revenue AS total_revenue,
    sub.year_product_revenue / sub.year_order_count AS aov,
    sub.year_freight_revenue / sub.year_order_count AS avg_shipping_income,
    sub.year_freight_revenue
    / sub.year_product_revenue AS freight_to_product_ratio
FROM (
    SELECT
        -- r.*,
        r.year_number,
        -- r.total_product_revenue,
        -- r.total_freight_revenue
        SUM(r.order_count) AS year_order_count,
        SUM(r.total_product_revenue) AS year_product_revenue,
        SUM(r.total_freight_revenue) AS year_freight_revenue
    FROM #order_revenue AS r
    GROUP BY r.year_number
) AS sub
ORDER BY sub.year_number

-- quarter
SELECT
    sub.*,
    sub.quarter_product_revenue + sub.quarter_freight_revenue AS total_revenue,
    sub.quarter_product_revenue / sub.quarter_order_count AS aov,
    sub.quarter_freight_revenue
    / sub.quarter_order_count AS avg_shipping_income,
    sub.quarter_freight_revenue
    / sub.quarter_product_revenue AS freight_to_product_ratio
FROM (
    SELECT
        r.year_number,
        r.quarter_number,
        SUM(r.order_count) AS quarter_order_count,
        SUM(r.total_product_revenue) AS quarter_product_revenue,
        SUM(r.total_freight_revenue) AS quarter_freight_revenue
    FROM #order_revenue AS r
    GROUP BY r.year_number, r.quarter_number
) AS sub
ORDER BY sub.year_number, sub.quarter_number

-- month
SELECT
    sub.*,
    sub.month_product_revenue + sub.month_freight_revenue AS total_revenue,
    sub.month_product_revenue / sub.month_order_count AS aov,
    sub.month_freight_revenue / sub.month_order_count AS avg_shipping_income,
    sub.month_freight_revenue
    / sub.month_product_revenue AS freight_to_product_ratio
FROM (
    SELECT
        r.year_number,
        r.month_number,
        SUM(r.order_count) AS month_order_count,
        SUM(r.total_product_revenue) AS month_product_revenue,
        SUM(r.total_freight_revenue) AS month_freight_revenue
    FROM #order_revenue AS r
    GROUP BY r.year_number, r.month_number
) AS sub
ORDER BY sub.year_number, sub.month_number

-- week
SELECT
    sub.*,
    sub.week_product_revenue + sub.week_freight_revenue AS total_revenue,
    sub.week_product_revenue / sub.week_order_count AS aov,
    sub.week_freight_revenue / sub.week_order_count AS avg_shipping_income,
    sub.week_freight_revenue
    / sub.week_product_revenue AS freight_to_product_ratio
FROM (
    SELECT
        r.year_number,
        r.week_number,
        SUM(r.order_count) AS week_order_count,
        SUM(r.total_product_revenue) AS week_product_revenue,
        SUM(r.total_freight_revenue) AS week_freight_revenue
    FROM #order_revenue AS r
    GROUP BY r.year_number, r.week_number
) AS sub
ORDER BY sub.year_number, sub.week_number

-- day
SELECT
    sub.*,
    sub.day_product_revenue + sub.day_freight_revenue AS total_revenue,
    sub.day_product_revenue / sub.day_order_count AS aov,
    sub.day_freight_revenue / sub.day_order_count AS avg_shipping_income,
    sub.day_freight_revenue
    / sub.day_product_revenue AS freight_to_product_ratio
FROM (
    SELECT
        r.full_date,
        r.year_number,
        r.day_of_year,
        SUM(r.total_product_revenue) AS day_product_revenue,
        SUM(r.total_freight_revenue) AS day_freight_revenue,
        SUM(r.order_count) AS day_order_count
    FROM #order_revenue AS r
    GROUP BY r.year_number, r.day_of_year, r.full_date
) AS sub
ORDER BY sub.full_date

-- ==================================================
-- OLD ATTEMPT
-- same result as new attempt
-- filter, aggregate at query
-- more versitile, option to change grain at query
-- ==================================================

-- get obt order sales
SELECT
    d.*,
    sub.*
INTO #order_sales
FROM (
    SELECT
        -- o.*,
        -- oi.*
        o.order_id,
        oi.order_item_id,
        o.order_status,
        -- o.order_purchase_timestamp,
        o.order_approved_at,
        CAST(DATETRUNC(DAY, o.order_approved_at) AS DATE)
            AS order_purchase_date,
        CONVERT(TIME, o.order_approved_at) AS order_purchase_time,
        oi.price AS order_price,
        oi.freight_value AS order_freight_value
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
        -- and o.order_id = '8272b63d03f5f79c56e9e4120aec44ef'
        -- and oi.order_item_id = 21
) AS sub
RIGHT JOIN utils.dim_date AS d
    ON sub.order_purchase_date = d.full_date
ORDER BY d.full_date;

DROP TABLE #order_sales

-- find distinct order statuses
SELECT DISTINCT o.order_status
FROM sales.fact_orders AS o

/*
approved
delivered
created
invoiced
processing
unavailable
canceled
shipped
*/

SELECT *
FROM #order_sales AS os
ORDER BY os.full_date

-- AOV year
SELECT
    os.year_number AS [year],
    SUM(os.order_price) AS year_product_revenue,
    SUM(os.order_freight_value) AS year_freight_revenue,
    SUM(os.order_price + os.order_freight_value) AS year_gross_revenue,
    COUNT(DISTINCT os.order_id) AS year_order_count,
    SUM(os.order_price) / COUNT(DISTINCT os.order_id) AS something
FROM #order_sales AS os
GROUP BY os.year_number
ORDER BY os.year_number

-- AOV quarter
SELECT
    -- os.year_number,
    -- os.quarter_number,
    CONCAT(
        'FY', RIGHT(os.year_number, 2), ' Q', os.quarter_number
    ) AS quarter,
    SUM(os.order_price) AS total_revenue,
    COUNT(DISTINCT os.order_id) AS total_distinct_orders,
    SUM(os.order_price) / COUNT(DISTINCT os.order_id) AS aov_per_quarter
FROM #order_sales AS os
GROUP BY os.year_number, os.quarter_number
ORDER BY os.year_number, os.quarter_number


-- AOV month
SELECT
    -- os.year_number as [year],
    CONCAT(
        FORMAT(DATEFROMPARTS(1900, os.month_number, 1), 'MMM'),
        ' ',
        os.year_number
    ) AS [month],
    SUM(os.order_price) AS total_revenue,
    COUNT(DISTINCT os.order_id) AS total_distinct_orders,
    SUM(os.order_price) / COUNT(DISTINCT os.order_id) AS aov_per_month
FROM #order_sales AS os
GROUP BY os.year_number, os.month_number
ORDER BY os.year_number, os.month_number

-- AOV week
-- want to say week comencing
-- YYwWW
SELECT
    -- os.year_number,
    -- os.week_number,
    -- datetrunc(week, os.full_date) as full_date,
    CONCAT(
        RIGHT(os.year_number, 2),
        'w',
        FORMAT(os.week_number, '00')
    ) AS [week],
    SUM(os.order_price) AS total_revenue,
    COUNT(DISTINCT os.order_id) AS total_distinct_orders,
    SUM(os.order_price) / COUNT(DISTINCT os.order_id) AS aov
FROM #order_sales AS os
GROUP BY os.year_number, os.week_number
ORDER BY os.year_number, os.week_number


-- AOV day
SELECT
    os.year_number,
    os.day_of_year,
    SUM(os.order_price) AS total_revenue,
    COUNT(DISTINCT os.order_id) AS total_distinct_orders,
    SUM(os.order_price) / COUNT(DISTINCT os.order_id) AS aov_per_day
FROM #order_sales AS os
GROUP BY os.year_number, os.day_of_year
ORDER BY os.year_number, os.day_of_year
