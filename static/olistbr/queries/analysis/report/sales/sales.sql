USE olist;
GO

WITH agg_sales AS (
    SELECT
        s.year_number,
        s.month_number,
        COUNT(DISTINCT s.order_id) AS order_count,
        SUM(s.price) AS product_revenue,
        SUM(s.freight_value) AS freight_revenue
    FROM sales.vw_sales_practical AS s
    GROUP BY
        s.year_number,
        s.month_number
),

calculated_sales AS (
    SELECT
        s.*,
        s.product_revenue + s.freight_revenue AS gmv,
        s.product_revenue + s.freight_revenue / s.order_count AS aov
    FROM agg_sales AS s
),

lag_sales AS (
    SELECT
        s.*,
        LAG(s.order_count) OVER (
            ORDER BY
                s.year_number,
                s.month_number
        ) AS lag_order_count,
        LAG(s.gmv) OVER (
            ORDER BY
                s.year_number,
                s.month_number
        ) AS lag_gmv,
        LAG(s.aov) OVER (
            ORDER BY
                s.year_number,
                s.month_number
        ) AS lag_aov
    FROM calculated_sales AS s
),

growth_sales AS (
    SELECT
        s.*,
        utils.fn_pcc(s.lag_order_count, s.order_count) AS order_count_pc_growth,
        utils.fn_pcc(s.lag_gmv, s.gmv) AS gmv_pc_growth,
        utils.fn_pcc(s.lag_aov, s.aov) AS aov_pc_growth
    FROM lag_sales AS s
)

SELECT
    s.year_number,
    s.month_number,
    s.order_count AS total_sales,
    -- s.product_revenue,
    -- s.freight_revenue,
    utils.fn_format_brl(s.gmv) AS gmv,
    utils.fn_format_brl(s.aov) AS aov,
    FORMAT(s.aov_pc_growth, 'P') AS aov_periodic
FROM growth_sales AS s
ORDER BY
    s.year_number,
    s.month_number;
GO

-- =
-- random analysis
SELECT o.order_purchase_timestamp
FROM sales.fact_orders AS o
    LEFT JOIN sales.fact_order_items AS oi
        ON o.order_id = oi.order_id
ORDER BY o.order_purchase_timestamp ASC
