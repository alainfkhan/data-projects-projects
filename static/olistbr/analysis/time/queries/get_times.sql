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

-- year_number purchase times
/*
use find and replace on year_number
df_dow_pt
df_dom_pt
df_doy_pt
df_wn_pt
df_mn_pt
df_qn_pt
df_yn_pt
*/
WITH year_number_purchase_times AS (
    SELECT
        o.year_number,
        CONVERT(TIME, o.order_purchase_timestamp) AS purchase_time,
        DATEDIFF(SECOND, o.order_purchase_timestamp, order_approved_at)
            AS diff_purchase_to_approve_s
    FROM sales.vw_orders_practical AS o
)

SELECT
    o.*,
    COUNT(*) AS order_count
FROM year_number_purchase_times AS o
GROUP BY
    o.year_number,
    o.purchase_time,
    o.diff_purchase_to_approve_s
ORDER BY
    o.year_number,
    o.purchase_time,
    o.diff_purchase_to_approve_s;
