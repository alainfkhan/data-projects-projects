USE olist_stg;

-- short analysis
select
    c.*
from sales.dim_customers as c

-- 99441 distinct customer ids
-- 96096 distinct customer unique id
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
    count(distinct c.customer_unique_id) as active_customers,
    count(distinct o.order_id) as order_count
from sales.fact_orders as o
left join sales.dim_customers as c
    on o.customer_id = c.customer_id
right join utils.dim_date as d
    on cast(o.order_purchase_timestamp as date) = d.full_date
group by
    d.year_number,
    d.month_number
order by
    d.year_number,
    d.month_number

/*
customer_unique_id_count is active customers
*/