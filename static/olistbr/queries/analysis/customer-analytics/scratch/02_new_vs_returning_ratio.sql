USE olist_stg;
-- NEED TO REDO

-- new vs returning customer ratio?

WITH fod AS (
    SELECT
        o.customer_id,
        MIN(CAST(o.order_purchase_timestamp AS DATE)) AS first_order_date
    FROM sales.fact_orders AS o
    GROUP BY o.customer_id
    -- order by first_order_date asc
)

SELECT
    d.year_number,
    d.month_number,
    SUM(sub.is_first_order_date) AS new_customer_count,
    SUM(CASE
        WHEN sub.is_first_order_date IS NULL
            THEN NULL
        WHEN sub.is_first_order_date = 0
            THEN 1
            ELSE 0
    END) AS returning_customer_count
FROM (
    SELECT
        -- d.*,
        -- o.*,
        -- fod.*
        d.year_number,
        d.month_number,
        d.full_date,
        o.customer_id,
        fod.first_order_date,
        CASE WHEN d.full_date = fod.first_order_date
            THEN 1
            ELSE 0
        END AS is_first_order_date
    FROM sales.fact_orders AS o
    LEFT JOIN fod
        ON fod.customer_id = o.customer_id
    LEFT JOIN utils.dim_date AS d
        ON CAST(o.order_purchase_timestamp AS DATE) = d.full_date
) AS sub
RIGHT JOIN utils.dim_date AS d
    ON sub.full_date = d.full_date
GROUP BY
    d.year_number,
    d.month_number
ORDER BY
    d.year_number,
    d.month_number

/*
all customers in this dataset are new customers
*/

-- count unique customer ids: 99441
SELECT COUNT(DISTINCT o.customer_id) FROM sales.fact_orders AS o
SELECT COUNT(o.customer_id) FROM sales.fact_orders AS o
SELECT COUNT(c.customer_id) FROM sales.dim_customers AS c
