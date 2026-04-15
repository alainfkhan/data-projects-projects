USE olist;

-- ==================================================
-- purchase times
/*
the datetime of any order created by the user
*/
-- ==================================================

-- purchase times within a day
SELECT
    CONVERT(TIME, o.order_purchase_timestamp) AS purchase_time,
    COUNT(*) AS order_count
FROM sales.vw_orders_practical AS o
GROUP BY CONVERT(TIME, o.order_purchase_timestamp)
ORDER BY purchase_time;

-- day_of_month purchase times
/*
use find and replace on day_of_month
*/
WITH day_of_month_purchase_times AS (
    SELECT
        o.day_of_month,
        CONVERT(TIME, o.order_purchase_timestamp) AS purchase_time,
        DATEDIFF(SECOND, o.order_purchase_timestamp, order_approved_at)
            AS diff_purchase_to_approve_s
    FROM sales.vw_orders_practical AS o
)

SELECT
    o.*,
    COUNT(*) AS order_count
FROM day_of_month_purchase_times AS o
GROUP BY
    o.day_of_month,
    o.purchase_time,
    o.diff_purchase_to_approve_s
ORDER BY
    o.day_of_month,
    o.purchase_time,
    o.diff_purchase_to_approve_s;
