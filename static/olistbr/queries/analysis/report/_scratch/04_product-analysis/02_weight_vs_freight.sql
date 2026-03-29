USE olist_stg;
GO;

-- TODO: in excel (for practice)

-- does weight affect freight
-- ie. does weight cause freight
-- correlation !=> causation

-- ==================================================
WITH cov_part_values AS (
    SELECT DISTINCT
        pt.product_category_name_english,
        -- p.product_weight_g,
        -- oi.freight_value
        COUNT(*) AS n,  -- appearances?
        SUM(1.0 * p.product_weight_g) AS sum_x,
        SUM(SQUARE(1.0 * p.product_weight_g)) AS sum_sq_x,
        SUM(1.0 * oi.freight_value) AS sum_y,
        SUM(SQUARE(1.0 * oi.freight_value)) AS sum_sq_y,
        SUM(1.0 * p.product_weight_g * oi.freight_value) AS sum_xy
    FROM sales.fact_orders AS o
        LEFT JOIN sales.fact_order_items AS oi
            ON o.order_id = oi.order_id
        LEFT JOIN sales.dim_products AS p
            ON oi.product_id = p.product_id
        LEFT JOIN sales.dim_product_category_name_translation AS pt
            ON p.product_category_name = pt.product_category_name
    WHERE
        pt.product_category_name_english IS NOT NULL
        AND p.product_weight_g IS NOT NULL
        AND oi.freight_value IS NOT NULL
    GROUP BY
        pt.product_category_name_english
)

SELECT
    -- c.*,
    c.product_category_name_english,
    c.n,
    (c.n * c.sum_xy - sum_x * sum_y)
    / NULLIF(
        (
            SQRT(c.n * c.sum_sq_x - SQUARE(sum_x))
            * SQRT(c.n * c.sum_sq_y - SQUARE(sum_y))
        ),
        0
    ) AS corr_weight_freight
INTO #corr_weight_freight
FROM cov_part_values AS c
ORDER BY corr_weight_freight DESC
GO;

/*
DROP TABLE #corr_weight_freight
*/

/*
product_category_name_english, n, corr_weight_freight
security_and_services, 2, 0.9999999999999996
arts_and_craftmanship, 24, 0.8280962503655963
fashion_sport, 30, 0.7748094224432427
la_cuisine, 14, 0.7743581296550879
market_place, 311, 0.7208589101151077
small_appliances_home_oven_and_coffee, 76, 0.7095594159903362
small_appliances, 679, 0.7010162923282609
construction_tools_lights, 304, 0.6993337682135085
health_beauty, 9670, 0.696506374281815
furniture_living_room, 503, 0.6959616992931418
agro_industry_and_commerce, 212, 0.6822100050805389

all
n, corr_weight_freight
111022, 0.6113323281612338
*/

-- ==========
-- significant when n > median
WITH tbl_median AS (
    -- median
    SELECT DISTINCT
        PERCENTILE_CONT(0.5) WITHIN GROUP (
ORDER BY c.n) OVER () AS median
    FROM #corr_weight_freight AS c
),

tbl_with_median AS (
    SELECT
        c.*,
        m.*
    FROM #corr_weight_freight AS c
        CROSS JOIN tbl_median AS m
)

SELECT
    m.product_category_name_english,
    m.n,
    FORMAT(m.corr_weight_freight, '0.###') AS corr_weight_freight
FROM tbl_with_median AS m
WHERE m.n > m.median
ORDER BY m.corr_weight_freight DESC;
GO

-- ==========
-- significant when n > average

SELECT
    c.product_category_name_english,
    c.n,
    FORMAT(c.corr_weight_freight, '0.###') AS corr_weight_freight
FROM #corr_weight_freight AS c
WHERE c.n > (
    SELECT AVG(c.n)
    FROM #corr_weight_freight AS c
)
ORDER BY c.corr_weight_freight DESC;
GO

-- ==========

SELECT
    pt.product_category_name_english,
    p.product_weight_g,
    oi.freight_value
FROM sales.fact_orders AS o
    LEFT JOIN sales.fact_order_items AS oi
        ON o.order_id = oi.order_id
    LEFT JOIN sales.dim_products AS p
        ON oi.product_id = p.product_id
    LEFT JOIN sales.dim_product_category_name_translation AS pt
        ON p.product_category_name = pt.product_category_name
WHERE pt.product_category_name_english = 'arts_and_craftmanship'
ORDER BY
    p.product_weight_g,
    oi.freight_value
