USE olist;
GO

-- select o.month_number, o.order_id
-- from sales.vw_orders as o
-- -- where o.order_id is not null
-- order by o.key_date, o.order_purchase_timestamp

WITH cte_sales AS (
    SELECT
        s.year_number,
        s.month_number,
        COUNT(DISTINCT s.order_id) AS order_count,
        SUM(s.price) AS product_revenue,
        SUM(s.freight_value) AS freight_revenue
    FROM sales.vw_orders AS s
    GROUP BY
        s.year_number,
        s.month_number
),

agg_sales AS (
    SELECT
        s.*,
        s.product_revenue + s.freight_revenue AS gmv,
        s.product_revenue + s.freight_revenue / s.order_count AS aov
    FROM cte_sales AS s
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
    FROM agg_sales AS s
)

SELECT
    s.*,
    utils.fn_pcc(s.lag_order_count, s.order_count) AS order_count_pc_growth,
    utils.fn_pcc(s.lag_gmv, s.gmv) AS gmv_pc_growth,
    utils.fn_pcc(s.lag_aov, s.aov) AS aov_pc_growth
FROM lag_sales AS s
ORDER BY
    s.year_number,
    s.month_number
