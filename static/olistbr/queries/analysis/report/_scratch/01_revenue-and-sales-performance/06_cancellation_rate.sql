USE olist_stg;

-- list tables
SELECT o.*
FROM sales.fact_orders AS o

SELECT oi.*
FROM sales.fact_order_items AS oi
GO;

-- find cancellation rate through time
/*
cancellation is consumer side, so choose date as order_purchase_timestamp
*/
CREATE OR ALTER VIEW sales.vw_cancellation_rate AS
SELECT
    subb.*,
    subb.cancelled_count + subb.non_cancelled_count AS order_status_count,
    CAST(subb.cancelled_count AS DECIMAL(9, 8))
    / NULLIF(subb.cancelled_count + subb.non_cancelled_count, 0)
        AS cancellation_rate
FROM (
    SELECT
        d.full_date,
        SUM(CASE WHEN sub.order_status = 'canceled' THEN 1 ELSE 0 END)
            AS cancelled_count,
        SUM(CASE WHEN sub.order_status != 'canceled' THEN 1 ELSE 0 END)
            AS non_cancelled_count
    FROM (
        SELECT
            o.order_id,
            o.order_purchase_timestamp,
            CAST(o.order_purchase_timestamp AS DATE) AS order_purchase_date,
            o.order_status
        FROM sales.fact_orders AS o
    ) AS sub
        RIGHT JOIN utils.dim_date AS d
            ON sub.order_purchase_date = d.full_date
    GROUP BY d.full_date
) AS subb

GO;
-- order by subb.full_date


-- ==================================================
-- cancellation rate through time
-- ==================================================

SELECT
    d.year_number,
    -- d.quarter_number,
    d.month_number,
    -- d.week_number,
    -- d.full_date,
    SUM(cr.cancelled_count) AS cancelled_count,
    SUM(cr.non_cancelled_count) AS non_cancelled_count,
    SUM(cr.order_status_count) AS order_status_count,
    AVG(cr.cancellation_rate) AS avg_cancellation_rate
FROM sales.vw_cancellation_rate AS cr
    LEFT JOIN utils.dim_date AS d
        ON cr.full_date = d.full_date
GROUP BY
    d.year_number,
    -- d.quarter_number
    d.month_number
    -- d.week_number
    -- d.full_date
ORDER BY
    d.year_number,
    -- d.quarter_number
    d.month_number
    -- d.week_number
    -- d.full_date
