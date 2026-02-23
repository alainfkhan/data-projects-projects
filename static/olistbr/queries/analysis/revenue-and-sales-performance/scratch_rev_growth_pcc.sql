use olist_stg;

-- revenue pc over time

-- list tables
select
    o.*
from sales.fact_orders as o

select
    oi.*
from sales.fact_order_items as oi

select distinct
    o.order_status
from sales.fact_orders as o
order by o.order_status

/*
approved
canceled
created
delivered
invoiced
processing
shipped
unavailable
*/

-- ==================================================
-- date on date revenue growth
/*
vim example:
    :s/month/quarter/g
    :s/month/week/g
    :s/month_number/full_date/g
*/
-- ==================================================

with agg as (
    select
        d.year_number,
        d.month_number,
        count(distinct s.order_id) as order_count,
        sum(s.price) as total_product_revenue,
        sum(s.freight_value) as total_freight_revenue,
        sum(s.price + s.freight_value) as total_revenue
    from sales.vw_sales as s
    right join utils.dim_date as d
        -- vim: keep s date key = d date key
        on s.date_key = d.date_key
    group by
        d.year_number,
        d.month_number
)
select
    a.year_number,
    a.month_number,
    a.order_count,
    1.0 * (a.order_count - a.lag_order_count) / nullif(a.lag_order_count, 0) as pcc_order_count,
    a.total_product_revenue,
    (a.total_product_revenue - a.lag_total_product_revenue) / nullif(a.lag_total_product_revenue, 0) as pcc_total_product_revenue,
    a.total_freight_revenue,
    (a.total_freight_revenue - a.lag_total_freight_revenue) / nullif(a.lag_total_freight_revenue, 0) as pcc_total_freight_revenue,
    a.total_revenue,
    (a.total_revenue - a.lag_total_revenue) / nullif(a.lag_total_revenue, 0) as pcc_total_revenue
from (
    select
        a.*,
        lag(a.order_count) over (
            order by
                a.year_number,
                a.month_number
        ) as lag_order_count,
        lag(a.total_product_revenue) over (
            order by
                a.year_number,
                a.month_number
        ) as lag_total_product_revenue,
        lag(a.total_freight_revenue) over (
            order by
                a.year_number,
                a.month_number
        ) as lag_total_freight_revenue,
        lag(a.total_revenue) over (
            order by
                a.year_number,
                a.month_number
        ) as lag_total_revenue
    from agg as a
) as a
where a.year_number in (
    '2016',
    '2017',
    '2018'
)
order by
    a.year_number,
    a.month_number





