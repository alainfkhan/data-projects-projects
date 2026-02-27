USE olist_stg;

-- short analysis
SELECT c.*
FROM sales.dim_customers AS c

-- 99441 distinct customer ids
-- 96096 distinct customer unique ids
SELECT
    COUNT(DISTINCT c.customer_unique_id) AS customer_unique_id_count,
    COUNT(DISTINCT c.customer_id) AS customer_id_count
FROM sales.dim_customers AS c

/*
on customer side
use order_purchase_timestamp as anchor date
any customer who in the orders table
active customers is customer count
*/
-- ==================================================
-- active customers through time
/*
careful with find and replace join on date keep d full date
can find yau, qau, mau, wau, dau
*/
-- ==================================================

SELECT
    c.year_number,
    c.month_number,
    c.order_count,
    c.active_users,
    1.0 * c.order_count / NULLIF(c.active_users, 0) AS avg_orders_per_user,
    1.0
    * c.total_product_revenue
    / NULLIF(c.active_users, 0) AS avg_potential_product_revenue_per_user,
    1.0
    * c.total_freight_revenue
    / NULLIF(c.active_users, 0) AS avg_potential_freight_revenue_per_user,
    1.0
    * c.total_revenue
    / NULLIF(c.active_users, 0) AS avg_unrealised_total_revenue_per_user
FROM (
    SELECT
        d.year_number,
        d.month_number,
        COUNT(DISTINCT o.order_id) AS order_count,
        COUNT(DISTINCT c.customer_unique_id) AS active_users,
        SUM(oi.price) AS total_product_revenue,
        SUM(oi.freight_value) AS total_freight_revenue,
        SUM(oi.price + oi.freight_value) AS total_revenue
    FROM sales.fact_orders AS o
    LEFT JOIN sales.fact_order_items AS oi
        ON o.order_id = oi.order_id
    LEFT JOIN sales.dim_customers AS c
        ON o.customer_id = c.customer_id
    RIGHT JOIN utils.dim_date AS d
        ON CAST(o.order_purchase_timestamp AS DATE) = d.key_date
    WHERE d.year_number BETWEEN 2016 AND 2018
    GROUP BY
        d.year_number,
        d.month_number
) AS c
ORDER BY
    c.year_number,
    c.month_number


/*
customer_unique_id_count is active customers
*/

-- validation

SELECT
    SUM(sub.d_cuid) AS total_d_cuid,    -- 98046
    SUM(sub.cuid) AS total_cuid         -- 99441
FROM (
    SELECT
        -- o.*,
        -- c.*
        d.year_number,
        d.month_number,
        COUNT(DISTINCT c.customer_unique_id) AS d_cuid,
        COUNT(c.customer_unique_id) AS cuid
    FROM sales.fact_orders AS o
    LEFT JOIN sales.dim_customers AS c
        ON o.customer_id = c.customer_id
    LEFT JOIN utils.dim_date AS d
        ON CAST(o.order_purchase_timestamp AS DATE) = d.full_date
    GROUP BY
        d.year_number,
        d.month_number
    ORDER BY
        d.year_number,
        d.month_number
) AS sub

-- 96096 total customer_unique_ids
SELECT COUNT(DISTINCT c.customer_unique_id)
FROM sales.dim_customers AS c

SELECT COUNT(DISTINCT c.customer_unique_id)
    -- o.customer_id,
    -- c.customer_id,
    -- c.customer_unique_id
    -- 96096
FROM sales.fact_orders AS o
FULL OUTER JOIN sales.dim_customers AS c
    ON o.customer_id = c.customer_id
