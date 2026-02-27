USE olist_stg;
-- TODO: rename end table columns

-- ================================================== 
-- new vs returning customer ratio?
/*
*/
-- ================================================== 

-- start
-- ================================================== 
GO;

WITH fod AS (
    SELECT
        c.customer_unique_id,
        MIN(CAST(o.order_purchase_timestamp AS DATE)) AS first_order_date
    FROM sales.fact_orders AS o
    LEFT JOIN sales.dim_customers AS c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    -- order by first_order_date
),

ifod AS (
    SELECT
        d.*,
        o.*,
        fod.*,
        CASE WHEN d.key_date = fod.first_order_date
            THEN 1
            ELSE 0
        END AS is_first_order_date
    FROM sales.fact_orders AS o
    LEFT JOIN sales.dim_customers AS c
        ON o.customer_id = c.customer_id
    LEFT JOIN fod
        ON fod.customer_unique_id = c.customer_unique_id
    LEFT JOIN utils.dim_date AS d
        ON CAST(o.order_purchase_timestamp AS DATE) = d.key_date
),
-- )
-- select
--     -- ifod.*
--     sum(ifod.is_first_order_date)
-- from ifod
-- -- order by ifod.date_key

counts AS (
    SELECT
        d.year_number,
        d.month_number,
        COUNT(DISTINCT CASE
            WHEN ifod.is_first_order_date = 1
                THEN ifod.customer_unique_id
        END) AS new_users,
        COUNT(DISTINCT CASE
            WHEN ifod.is_first_order_date = 0
                THEN ifod.customer_unique_id
        END) AS repeat_users,
        SUM(ifod.is_first_order_date) AS new_user_orders,
        SUM(CASE
            -- when ifod.is_first_order_date is null
            --     then null
            WHEN ifod.is_first_order_date = 0
                THEN 1
                ELSE 0
        END) AS repeat_user_orders
    FROM ifod
    RIGHT JOIN utils.dim_date AS d
        ON ifod.date_key = d.date_key
    GROUP BY
        d.year_number,
        d.month_number
)
-- select
--     c.*
-- from counts as c
-- order by
--     c.year_number,
--     c.month_number

SELECT
    c.year_number,
    c.month_number,
    c.new_users,
    c.repeat_users,
    c.new_user_orders,
    c.repeat_user_orders,
    c.new_user_orders + c.repeat_user_orders AS total_user_orders,
    1.0
    * c.repeat_user_orders
    / NULLIF(c.new_user_orders + c.repeat_user_orders, 0)
        AS repeat_vs_total_user_orders
FROM counts AS c
WHERE c.year_number BETWEEN 2016 AND 2018
ORDER BY
    c.year_number,
    c.month_number

GO;
-- ================================================== 
-- end

/* explanation
customer side => use order_purcahse_timestamp as time customer made the order

new_users
    humans who ordered, who have not ordered before
    users acquired
    given is_first_order_date, count distinct customer_unique_ids
    the column sum is total distinct customer_unique_ids = 96096
    shows the distribution of new humans

repeat_users
    humans who ordered, who have ordered before
    users retained
    given not is_first_order_date, count distinct customer_unique_ids

first_user_orders
    orders made by new_users
    is a partition of total_orders

repeat_user_orders
    orders made by repeat_users
    is a partition of total_orders

total_user_orders
    first_user_orders + repeat_user_orders = 99441
    = order_count

*/

-- last orders

WITH ro AS (
    SELECT
        d.*,
        ro.*
    FROM (
        SELECT
            o.order_purchase_timestamp,
            CAST(o.order_purchase_timestamp AS DATE) AS order_purchase_date,
            o.customer_id,
            c.customer_unique_id,
            c.customer_zip_code_prefix,
            c.customer_city,
            c.customer_state,
            ROW_NUMBER() OVER (
                PARTITION BY c.customer_unique_id
                ORDER BY
                    o.order_purchase_timestamp DESC
            ) AS rn
        FROM sales.fact_orders AS o
        LEFT JOIN sales.dim_customers AS c
            ON o.customer_id = c.customer_id
    ) AS ro
    LEFT JOIN utils.dim_date AS d
        ON ro.order_purchase_date = d.key_date
    WHERE ro.rn = 1
)

SELECT
    -- ro.*
    d.year_number,
    d.month_number,
    COUNT(ro.customer_unique_id) AS last_orders
FROM ro
RIGHT JOIN utils.dim_date AS d
    ON ro.date_key = d.date_key
GROUP BY
    d.year_number,
    d.month_number
ORDER BY
    d.year_number,
    d.month_number

-- scratch

-- 96096 distinct customer_unique_ids
SELECT COUNT(DISTINCT c.customer_unique_id)
FROM sales.dim_customers AS c

-- 2997 distinct customer_unique_ids that have ordered more than once
-- 252 distinct customer_unique_ids that have ordered more than twice
-- 49 distinct customer_unique_ids that have ordered more than three times
-- 19 distinct customer_unique_ids that have ordered more than four times
-- 11 distinct customer_unique_ids that have ordered more than five times
-- 5 distinct customer_unique_ids that have ordered more than six times
SELECT COUNT(DISTINCT sub.customer_unique_id)
    -- count(sub.customer_unique_id)
FROM (
    SELECT
        c.customer_unique_id,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY c.customer_unique_id
        ) AS rn
    FROM sales.dim_customers AS c
) AS sub
WHERE sub.rn > 1

/*
count no dist: 3345
count dist: 2997
*/

-- ================================================== 
-- old
/*
nested cte in subquery, hard to debug
*/
-- ================================================== 

WITH fod AS (
    SELECT
        c.customer_unique_id,
        MIN(CAST(o.order_purchase_timestamp AS DATE)) AS first_order_date
    FROM sales.fact_orders AS o
    LEFT JOIN sales.dim_customers AS c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
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
        c.customer_unique_id,
        fod.first_order_date,
        CASE WHEN d.full_date = fod.first_order_date
            THEN 1
            ELSE 0
        END AS is_first_order_date
    FROM sales.fact_orders AS o
    LEFT JOIN sales.dim_customers AS c
        ON o.customer_id = c.customer_id
    -- LEFT JOIN fod
    --     ON fod.customer_unique_id = c.customer_unique_id
    LEFT JOIN (

        SELECT
            c.customer_unique_id,
            MIN(CAST(o.order_purchase_timestamp AS DATE)) AS first_order_date
        FROM sales.fact_orders AS o
        LEFT JOIN sales.dim_customers AS c
            ON o.customer_id = c.customer_id
        GROUP BY c.customer_unique_id

    ) AS fod
        ON fod.customer_unique_id = c.customer_unique_id
    LEFT JOIN utils.dim_date AS d
        ON CAST(o.order_purchase_timestamp AS DATE) = d.full_date
    -- where d.full_date != fod.first_order_date
    -- order by d.date_key

) AS sub
RIGHT JOIN utils.dim_date AS d
    ON sub.full_date = d.full_date
GROUP BY
    d.year_number,
    d.month_number
ORDER BY
    d.year_number,
    d.month_number

-- rough analysis
SELECT
    c.*,
    o.*,
    oi.*
FROM sales.dim_customers AS c
LEFT JOIN sales.fact_orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN sales.fact_order_items AS oi
    ON o.order_id = oi.order_id
WHERE c.customer_unique_id = 'e23daf58ce481f3d38066e654ef610cb'

/*
customer unique ids with repeat orders:
e23daf58ce481f3d38066e654ef610cb
c76762dfb642ac154475239639f7f8f4
*/


/*
all customers in this dataset are new customers
*/

-- count unique customer ids: 99441
SELECT COUNT(DISTINCT o.customer_id) FROM sales.fact_orders AS o
SELECT COUNT(o.customer_id) FROM sales.fact_orders AS o
SELECT COUNT(c.customer_id) FROM sales.dim_customers AS c
