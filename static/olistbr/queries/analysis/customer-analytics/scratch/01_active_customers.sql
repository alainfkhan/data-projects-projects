USE olist_stg;
-- NEED TO REDO

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
*/
-- ==================================================

SELECT
    d.year_number,
    d.month_number,
    COUNT(DISTINCT o.customer_id) AS active_customers
FROM sales.fact_orders AS o
RIGHT JOIN utils.dim_date AS d
    ON CAST(o.order_purchase_timestamp AS DATE) = d.full_date
    -- -- using fn is 3x slower
    -- on utils.fn_datetime_to_datekey(o.order_purchase_timestamp) = d.date_key 
GROUP BY
    d.year_number,
    d.month_number
ORDER BY
    d.year_number,
    d.month_number
