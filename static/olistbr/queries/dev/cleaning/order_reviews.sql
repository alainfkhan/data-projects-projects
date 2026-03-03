USE olist;

SELECT DISTINCT
    o.order_id AS orders_order_id,
    orev.order_id AS order_reviews_order_id
FROM sales.fact_orders AS o
    LEFT JOIN sales.fact_order_reviews AS orev
        ON o.order_id = orev.order_id
WHERE
    o.order_id IS NULL
    OR orev.order_id IS NULL;

/*
768 distinct order ids exist in orders but not in order payments
dooids contains doroids
*/
