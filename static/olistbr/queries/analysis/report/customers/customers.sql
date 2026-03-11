USE olist;

-- ==================================================
-- active users
SELECT
    o.year_number,
    o.month_number,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT c.customer_unique_id) AS active_users,
    -- utils.fn_format_brl(sum(o.price)) as potential_max_product_revenue,
    -- utils.fn_format_brl(sum(o.freight_value)) as potential_max_freight_revenue,
    utils.fn_format_brl(SUM(o.price + o.freight_value))
        AS potential_max_total_revenue
FROM sales.vw_orders_practical AS o
    LEFT JOIN sales.dim_customers AS c
        ON o.customer_id = c.customer_id
GROUP BY
    o.year_number,
    o.month_number
ORDER BY
    o.year_number,
    o.month_number
