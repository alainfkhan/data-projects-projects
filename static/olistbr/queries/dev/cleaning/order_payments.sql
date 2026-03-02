USE olist_stg;

/*
find incomplete mappings
*/

SELECT DISTINCT
    o.order_id AS orders_order_id,
    op.order_id AS order_payments_order_id
FROM sales.fact_orders AS o
    LEFT JOIN sales.fact_order_payments AS op
        ON o.order_id = op.order_id
WHERE
    o.order_id IS NULL
    OR op.order_id IS NULL

/*
orders_order_id, order_payments_order_id
bfbd0f9bdef84302105ad712db648a6c, NULL
*/

-- analysis
SELECT o.*
FROM sales.fact_orders AS o
WHERE o.order_id = 'bfbd0f9bdef84302105ad712db648a6c'
