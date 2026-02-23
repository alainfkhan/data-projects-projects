use olist_stg;

-- want to show 1-1 relationship between o and c

-- inner join
select
    count(distinct c.customer_id),  --99441
    count(distinct o.customer_id)   --99441
from sales.dim_customers as c
inner join sales.fact_orders as o
    on c.customer_id = o.customer_id

-- count distinct customers
-- 99441
select
    count(distinct c.customer_id) as customer_count__dim_customers
from sales.dim_customers as c

-- 99441
select
    count(distinct o.customer_id) as customer_count__fact_orders
from sales.fact_orders as o

-- count distinct orders: 99441
select
    count(distinct o.order_id)
from sales.fact_orders as o

