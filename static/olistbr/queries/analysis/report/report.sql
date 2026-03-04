USE olist;

SELECT oi.*
FROM sales.fact_order_items AS oi

SELECT DISTINCT o.order_status
FROM sales.fact_orders AS o
ORDER BY o.order_status
