USE olist_stg;

-- want to show 1-1 relationship between o and c

-- inner join
SELECT
    COUNT(DISTINCT c.customer_id),  --99441
    COUNT(DISTINCT o.customer_id)   --99441
FROM sales.dim_customers AS c
INNER JOIN sales.fact_orders AS o
    ON c.customer_id = o.customer_id

-- count distinct customers
-- 99441
SELECT COUNT(DISTINCT c.customer_id) AS customer_count__dim_customers
FROM sales.dim_customers AS c

-- 99441
SELECT COUNT(DISTINCT o.customer_id) AS customer_count__fact_orders
FROM sales.fact_orders AS o

-- count distinct orders: 99441
SELECT COUNT(DISTINCT o.order_id)
FROM sales.fact_orders AS o

-- count 98666
SELECT COUNT(DISTINCT oi.order_id)
FROM sales.fact_order_items AS oi

-- full outer join where key is null for both
-- 775 = 99441 - 98666
SELECT
    o.order_id AS orders_order_id,
    oi.order_id AS order_items_order_id
FROM sales.fact_orders AS o
FULL OUTER JOIN sales.fact_order_items AS oi
    ON o.order_id = oi.order_id
WHERE
    o.order_id IS NULL
    OR oi.order_id IS NULL

SELECT oi.*
FROM sales.fact_order_items AS oi

-- customer unique id
SELECT COUNT(DISTINCT c.customer_unique_id)
FROM sales.dim_customers AS c
