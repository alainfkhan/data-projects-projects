USE olist;

-- ==================================================
-- weekly gmv
SELECT
    s.year_number,
    s.week_number,
    COUNT(DISTINCT s.order_id) AS order_count,
    -- sum(s.price) as product_revenue,
    -- sum(s.freight_value) as freight_revenue,
    utils.fn_format_brl(SUM(s.price + s.freight_value)) AS gmv
FROM sales.vw_sales_practical AS s
GROUP BY
    s.year_number,
    s.week_number
ORDER BY
    s.year_number,
    s.week_number
