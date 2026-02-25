use olist_stg;

-- one off analysis
-- 2017-01-05

select
    -- d.*,
    -- o.*,
    -- c.*,
    -- fod.*
    d.year_number,
    d.key_date,
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    cast(o.order_purchase_timestamp as date) as order_purchase_date,
    fod.first_order_date,
    case when cast(o.order_purchase_timestamp as date) = fod.first_order_date
        then 1
        else 0
    end as is_first_order_date
from sales.fact_orders as o
left join sales.dim_customers as c
    on o.customer_id = c.customer_id
left join utils.dim_date as d
    on cast(o.order_purchase_timestamp as date) = d.key_date
left join (

    select
        c.customer_unique_id,
        min(cast(o.order_purchase_timestamp as date)) as first_order_date
    from sales.fact_orders as o
    left join sales.dim_customers as c
        on o.customer_id = c.customer_id
    left join utils.dim_date as d
        on cast(o.order_purchase_timestamp as date) = d.key_date
    group by c.customer_unique_id

) as fod
    on c.customer_unique_id = fod.customer_unique_id
where d.key_date = '2017-01-05'

select
    -- d.*,
    -- o.*
    d.full_date,
    o.order_id,
    o.customer_id,
    c.customer_unique_id
from sales.fact_orders as o
left join sales.dim_customers as c
    on o.customer_id = c.customer_id
left join utils.dim_date as d
    on cast(o.order_purchase_timestamp as date) = d.key_date
where d.full_date = '2017-01-05'