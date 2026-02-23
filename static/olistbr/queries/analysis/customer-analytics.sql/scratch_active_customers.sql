use olist_stg;

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
    count(distinct o.customer_id) as active_customers
from sales.fact_orders as o
right join utils.dim_date as d
    on cast(o.order_purchase_timestamp as date) = d.full_date
    -- -- using fn is 3x slower
    -- on utils.fn_datetime_to_datekey(o.order_purchase_timestamp) = d.date_key 
group by
    d.year_number,
    d.month_number
order by
    d.year_number,
    d.month_number