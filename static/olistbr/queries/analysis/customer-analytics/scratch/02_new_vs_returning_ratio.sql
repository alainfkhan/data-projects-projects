USE olist_stg;

-- ================================================== 
-- new vs returning customer ratio?
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
),

ifod as (
    select
        d.*,
        o.*,
        fod.*,
        case when d.full_date = fod.first_order_date
            then 1
            else 0
        end as is_first_order_date
    from sales.fact_orders as o
    left join sales.dim_customers as c
        on o.customer_id = c.customer_id
    left join fod
        on fod.customer_unique_id = c.customer_unique_id
    left join utils.dim_date as d
        on cast(o.order_purchase_timestamp as date) = d.full_date
),

counts as (
    select
        d.year_number,
        d.month_number,
        sum(ifod.is_first_order_date) as new_customer_count,
        sum(case
            when ifod.is_first_order_date is null
                then null
            when ifod.is_first_order_date = 0
                then 1
                else 0
        end) as returning_customer_count
    from ifod
    right join utils.dim_date as d
        on ifod.date_key = d.date_key
    group by
        d.year_number,
        d.month_number
)

select
    c.*,
    1.0
    * c.returning_customer_count
    / nullif(c.new_customer_count + c.returning_customer_count, 0) as pc_returing_customers
from counts as c
order by
    c.year_number,
    c.month_number

go;


-- ================================================== 
-- old
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
