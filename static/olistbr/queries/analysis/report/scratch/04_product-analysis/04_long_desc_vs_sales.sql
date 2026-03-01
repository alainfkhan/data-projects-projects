USE olist_stg;

-- do longer product descriptions correlate with higher sales?
-- no

WITH cte AS (
    SELECT DISTINCT
        p.product_description_lenght AS x,
        -- sum(s.price) as total_product_revenue,
        -- sum(s.freight_value) as total_freight_revenue,
        SUM(s.price + s.freight_value) AS y
    FROM sales.vw_sales AS s
        LEFT JOIN sales.dim_products AS p
            ON s.product_id = p.product_id
        LEFT JOIN sales.dim_product_category_name_translation AS pt
            ON p.product_category_name = pt.product_category_name
    GROUP BY p.product_description_lenght
)
-- select
--     *
-- from cte

SELECT
    (COUNT(*) * SUM(x * y) - SUM(x) * SUM(y))
    / (
        SQRT(COUNT(*) * SUM(SQUARE(x)) - SQUARE(SUM(x)))
        * SQRT(COUNT(*) * SUM(SQUARE(y)) - SQUARE(SUM(y)))
    ) AS corr
FROM cte

/*
corr
-0.42102038891692506
*/
