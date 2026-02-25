USE olist_stg;
-- TODO: rename end table columns

-- ================================================== 
-- new vs returning customer ratio?
/*
*/
-- ================================================== 

-- start
-- ================================================== 
go;

with fod as (
    select
        c.customer_unique_id,
        min(cast(o.order_purchase_timestamp as date)) as first_order_date
    from sales.fact_orders as o
    left join sales.dim_customers as c
        on o.customer_id = c.customer_id
    group by c.customer_unique_id
    -- order by first_order_date
),

ifod as (
    select
        d.*,
        o.*,
        fod.*,
        case when d.key_date = fod.first_order_date
            then 1
            else 0
        end as is_first_order_date
    from sales.fact_orders as o
    left join sales.dim_customers as c
        on o.customer_id = c.customer_id
    left join fod
        on fod.customer_unique_id = c.customer_unique_id
    left join utils.dim_date as d
        on cast(o.order_purchase_timestamp as date) = d.key_date
),
-- )
-- select
--     -- ifod.*
--     sum(ifod.is_first_order_date)
-- from ifod
-- -- order by ifod.date_key

counts as (
    select
        d.year_number,
        d.month_number,
        count(distinct case
            when ifod.is_first_order_date = 1
                then ifod.customer_unique_id
        end) as new_customers,
        count(distinct case
            when ifod.is_first_order_date = 0 
                then ifod.customer_unique_id
        end) as repeat_customers,
        sum(ifod.is_first_order_date) as first_orders,
        sum(case
            -- when ifod.is_first_order_date is null
            --     then null
            when ifod.is_first_order_date = 0
                then 1
                else 0
        end) as repeat_orders
    from ifod
    right join utils.dim_date as d
        on ifod.date_key = d.date_key
    group by
        d.year_number,
        d.month_number
)
-- select
--     c.*
-- from counts as c
-- order by
--     c.year_number,
--     c.month_number

select
    c.year_number,
    c.month_number,
    c.new_customers,
    c.repeat_customers,
    c.first_orders,
    c.repeat_orders,
    c.first_orders + c.repeat_orders as total_orders,
    1.0
    * c.repeat_orders
    / nullif(c.first_orders + c.repeat_orders, 0) as repeat_vs_total_orders
from counts as c
where c.year_number between 2016 and 2018
order by
    c.year_number,
    c.month_number

go;
-- ================================================== 
-- end

/* explanation  
customer side => use order_purcahse_timestamp as time customer made the order

new_customers
    humans who ordered, who have not ordered before
    customers acquired
    given is_first_order_date, count distinct customer_unique_ids
    the column sum is total distinct customer_unique_ids = 96096
    shows the distribution of new humans
repeat_customers
    humans who ordered, who have ordered before
    customers retained
    given not is_first_order_date, count distinct customer_unique_ids

first_orders
    transactions made by new_customers
    is a partition of total_orders

repeat_orders
    transactions made by repeat_customers
    is a partition of total_orders

total_orders
    first_orders + repeat_orders = 99441
    total transactions
*/






-- scratch

-- 96096 distinct customer_unique_ids
select
    count(distinct c.customer_unique_id)
from sales.dim_customers as c

-- 2997 distinct customer_unique_ids that have ordered more than once
-- 252 distinct customer_unique_ids that have ordered more than twice
-- 49 distinct customer_unique_ids that have ordered more than three times
-- 19 distinct customer_unique_ids that have ordered more than four times
-- 11 distinct customer_unique_ids that have ordered more than five times
-- 5 distinct customer_unique_ids that have ordered more than six times
select
    -- count(sub.customer_unique_id)
    count(distinct sub.customer_unique_id)
from (
    select
        c.customer_unique_id,
        row_number() over (
            partition by c.customer_unique_id
            order by c.customer_unique_id
        ) as rn
    from sales.dim_customers as c
) as sub
where sub.rn > 1

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
    left join sales.dim_customers as c
        on o.customer_id = c.customer_id
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
    left join sales.dim_customers as c
        on o.customer_id = c.customer_id
    -- LEFT JOIN fod
    --     ON fod.customer_unique_id = c.customer_unique_id
    left join (

        SELECT
            c.customer_unique_id,
            MIN(CAST(o.order_purchase_timestamp AS DATE)) AS first_order_date
        FROM sales.fact_orders AS o
        left join sales.dim_customers as c
            on o.customer_id = c.customer_id
        GROUP BY c.customer_unique_id

    ) as fod
        on fod.customer_unique_id = c.customer_unique_id
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
select
    c.*,
    o.*,
    oi.*
from sales.dim_customers as c
left join sales.fact_orders as o
    on c.customer_id = o.customer_id
left join sales.fact_order_items as oi
    on o.order_id = oi.order_id
where c.customer_unique_id = 'e23daf58ce481f3d38066e654ef610cb'

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
