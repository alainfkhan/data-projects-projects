USE olist_stg;

-- one off analysis
-- 2017-01-05

SELECT
    -- d.*,
    -- o.*,
    -- c.*,
    -- fod.*
    d.year_number,
    d.key_date,
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    CAST(o.order_purchase_timestamp AS DATE) AS order_purchase_date,
    fod.first_order_date,
    CASE WHEN CAST(o.order_purchase_timestamp AS DATE) = fod.first_order_date
        THEN 1
        ELSE 0
    END AS is_first_order_date
FROM sales.fact_orders AS o
    LEFT JOIN sales.dim_customers AS c
        ON o.customer_id = c.customer_id
    LEFT JOIN utils.dim_date AS d
        ON CAST(o.order_purchase_timestamp AS DATE) = d.key_date
    LEFT JOIN (

        SELECT
            c.customer_unique_id,
            MIN(CAST(o.order_purchase_timestamp AS DATE)) AS first_order_date
        FROM sales.fact_orders AS o
        LEFT JOIN sales.dim_customers AS c
            ON o.customer_id = c.customer_id
        LEFT JOIN utils.dim_date AS d
            ON CAST(o.order_purchase_timestamp AS DATE) = d.key_date
        GROUP BY c.customer_unique_id

    ) AS fod
        ON c.customer_unique_id = fod.customer_unique_id
WHERE d.key_date = '2017-01-05'

SELECT
    -- d.*,
    -- o.*
    d.full_date,
    o.order_id,
    o.customer_id,
    c.customer_unique_id
FROM sales.fact_orders AS o
    LEFT JOIN sales.dim_customers AS c
        ON o.customer_id = c.customer_id
    LEFT JOIN utils.dim_date AS d
        ON CAST(o.order_purchase_timestamp AS DATE) = d.key_date
WHERE d.full_date = '2017-01-05'
