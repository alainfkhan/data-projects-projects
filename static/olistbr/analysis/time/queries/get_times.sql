/*
For prototyping queries to be sent through PYODBC
*/

USE olist;

-- ==================================================
-- purchase times
/*
the datetime of any order created by the user
*/
-- ==================================================

-- purchase times within a day
/*
df_day_pt
*/
SELECT
    CONVERT(TIME, o.order_purchase_timestamp) AS purchase_time,
    COUNT(*) AS order_count
FROM sales.vw_orders_practical AS o
GROUP BY CONVERT(TIME, o.order_purchase_timestamp)
ORDER BY purchase_time;

-- day_of_week purchase times
/*
use find and replace on day_of_week
df_pt_dow
df_pt_dom
df_pt_doy
df_pt_wn
df_pt_mn
df_pt_qn
df_pt_yn
*/
SELECT
    o.day_of_week,
    CONVERT(TIME, o.order_purchase_timestamp) AS purchase_time,
    DATEDIFF(SECOND, o.order_purchase_timestamp, order_approved_at)
        AS diff_purchase_to_approve_s,
    COUNT(*) AS order_count
FROM sales.vw_orders_practical AS o
GROUP BY
    o.day_of_week,
    CONVERT(TIME, o.order_purchase_timestamp),
    DATEDIFF(SECOND, o.order_purchase_timestamp, order_approved_at)
ORDER BY
    o.day_of_week,
    purchase_time,
    diff_purchase_to_approve_s;


-- ==================================================

select
    o.order_id,
    op.payment_type,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date
from sales.vw_orders_practical as o
left join sales.fact_order_payments as op
    on o.order_id = op.order_id

