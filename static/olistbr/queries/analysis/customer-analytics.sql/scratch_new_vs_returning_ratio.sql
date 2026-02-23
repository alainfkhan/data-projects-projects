use olist_stg;

-- new vs returning customer ratio?

with fod as (
    select 
        o.customer_id,
        min(cast(o.order_purchase_timestamp as date)) as first_order_date
    from sales.fact_orders as o
    group by o.customer_id
    -- order by first_order_date asc
)
select
    d.year_number,
    d.month_number,
    sum(sub.is_first_order_date) as new_customer_count,
    sum(case
        when sub.is_first_order_date is null
            then null
        when sub.is_first_order_date = 0
            then 1
            else 0
    end) as returning_customer_count
from (
    select
        -- d.*,
        -- o.*,
        -- fod.*
        d.year_number,
        d.month_number,
        d.full_date,
        o.customer_id,
        fod.first_order_date,
        case when d.full_date = fod.first_order_date
            then 1
            else 0
        end as is_first_order_date
    from sales.fact_orders as o
    left join fod
        on fod.customer_id = o.customer_id
    left join utils.dim_date as d
        on cast(o.order_purchase_timestamp as date) = d.full_date
) as sub
right join utils.dim_date as d
    on sub.full_date = d.full_date
group by 
    d.year_number,
    d.month_number
order by 
    d.year_number,
    d.month_number

/*
all customers in this dataset are new customers
*/

-- count unique customer ids: 99441
select count(distinct o.customer_id) from sales.fact_orders as o
select count(o.customer_id) from sales.fact_orders as o
select count(c.customer_id) from sales.dim_customers as c









