USE olist_stg;

-- revenue pc over time

-- list tables
SELECT o.*
FROM sales.fact_orders AS o

SELECT oi.*
FROM sales.fact_order_items AS oi

SELECT DISTINCT o.order_status
FROM sales.fact_orders AS o
ORDER BY o.order_status

/*
approved
canceled
created
delivered
invoiced
processing
shipped
unavailable
*/

-- ==================================================
-- date on date revenue growth
/*
vim example:
    :s/month/quarter/g
    :s/month/week/g
    :s/month_number/full_date/g
*/
-- ==================================================

WITH agg AS (
    SELECT
        d.year_number,
        d.month_number,
        COUNT(DISTINCT s.order_id) AS order_count,
        SUM(s.price) AS total_product_revenue,
        SUM(s.freight_value) AS total_freight_revenue,
        SUM(s.price + s.freight_value) AS total_revenue
    FROM sales.vw_sales AS s
        RIGHT JOIN utils.dim_date AS d
            -- vim: keep s date key = d date key
            ON s.date_key = d.date_key
    GROUP BY
        d.year_number,
        d.month_number
)

SELECT
    a.year_number,
    a.month_number,
    a.order_count,
    1.0
    * (a.order_count - a.lag_order_count)
    / NULLIF(a.lag_order_count, 0) AS pcc_order_count,
    a.total_product_revenue,
    (a.total_product_revenue - a.lag_total_product_revenue)
    / NULLIF(a.lag_total_product_revenue, 0) AS pcc_total_product_revenue,
    a.total_freight_revenue,
    (a.total_freight_revenue - a.lag_total_freight_revenue)
    / NULLIF(a.lag_total_freight_revenue, 0) AS pcc_total_freight_revenue,
    a.total_revenue,
    (a.total_revenue - a.lag_total_revenue)
    / NULLIF(a.lag_total_revenue, 0) AS pcc_total_revenue
FROM (
    SELECT
        a.*,
        LAG(a.order_count) OVER (
            ORDER BY
                a.year_number,
                a.month_number
        ) AS lag_order_count,
        LAG(a.total_product_revenue) OVER (
            ORDER BY
                a.year_number,
                a.month_number
        ) AS lag_total_product_revenue,
        LAG(a.total_freight_revenue) OVER (
            ORDER BY
                a.year_number,
                a.month_number
        ) AS lag_total_freight_revenue,
        LAG(a.total_revenue) OVER (
            ORDER BY
                a.year_number,
                a.month_number
        ) AS lag_total_revenue
    FROM agg AS a
) AS a
WHERE a.year_number IN (
    '2016',
    '2017',
    '2018'
)
ORDER BY
    a.year_number,
    a.month_number
