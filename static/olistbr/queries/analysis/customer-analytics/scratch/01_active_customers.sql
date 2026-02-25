USE olist_stg;

-- short analysis
select
    c.*
from sales.dim_customers as c

-- 99441 distinct customer ids
-- 96096 distinct customer unique ids
select
    count(distinct c.customer_unique_id) as customer_unique_id_count,
    count(distinct c.customer_id) as customer_id_count
from sales.dim_customers as c

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

select
    d.year_number,
    d.month_number,
    count(distinct o.order_id) as order_count,
    count(distinct c.customer_unique_id) as active_customers,
    1.0
    * count(distinct o.order_id)
    / nullif(count(distinct c.customer_unique_id), 0) as avg_orders_per_customer
from sales.fact_orders as o
left join sales.dim_customers as c
    on o.customer_id = c.customer_id
right join utils.dim_date as d
    on cast(o.order_purchase_timestamp as date) = d.full_date
where d.year_number between 2016 and 2018
group by
    d.year_number,
    d.month_number
order by
    d.year_number,
    d.month_number

/*
customer_unique_id_count is active customers
*/

-- validation

select
    sum(sub.d_cuid) as total_d_cuid,    -- 98046
    sum(sub.cuid) as total_cuid         -- 99441
from (
    select
        -- o.*,
        -- c.*
        d.year_number,
        d.month_number,
        count(distinct c.customer_unique_id) as d_cuid,
        count(c.customer_unique_id) as cuid
    from sales.fact_orders as o
    left join sales.dim_customers as c
        on o.customer_id = c.customer_id
    left join utils.dim_date as d
        on cast(o.order_purchase_timestamp as date) = d.full_date
    group by 
        d.year_number,
        d.month_number
    order by 
        d.year_number,
        d.month_number
) as sub

-- 96096 total customer_unique_ids
select
    count(distinct c.customer_unique_id)
from sales.dim_customers as c

select
    -- o.customer_id,
    -- c.customer_id,
    -- c.customer_unique_id
    count(distinct c.customer_unique_id)    -- 96096
from sales.fact_orders as o
full outer join sales.dim_customers as c
    on o.customer_id = c.customer_id



