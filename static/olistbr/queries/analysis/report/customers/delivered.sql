USE olist;

/*
delivered when:
    order_status = delivered
    or order_delivered_customer_date is not null
*/

-- delivered orders
WITH delivered_orders AS (
    SELECT DISTINCT o.order_id
    FROM sales.vw_orders_practical AS o
    WHERE
        o.order_status = 'delivered'
        OR o.order_delivered_customer_date IS NOT NULL
)

-- sales
SELECT s.*
FROM sales.vw_sales_practical AS s
WHERE s.order_id NOT IN (
    SELECT * FROM delivered_orders
)

-- 118 sales with unfulfilled deliveries
