use olist_stg

-- ==================================================
-- find GMV over any period

-- [)
declare @start_date datetime2 = '2018-01-01'
declare @end_date datetime2 = '2019-01-01'

-- orders
select
    o.*
into #orders_in_period
from sales.fact_orders as o
where o.order_approved_at >= @start_date
    and o.order_approved_at < @end_date
order by o.order_approved_at asc

select *
from #orders_in_period

-- order items
select
    oi.*
into #order_items_in_period
from sales.fact_order_items as oi
right join #orders_in_period as oip
    on oi.order_id = oip.order_id

select
    sum(oip.price) as GMV
from #order_items_in_period as oip

-- ending
drop table #orders_in_period
drop table #order_items_in_period

-- ==================================================

select
    o.*
from sales.fact_orders as o
where o.order_approved_at is not null
order by
    o.order_approved_at

-- order approved at null analysis
select distinct
    sub.order_status
from (
    select
        -- o.*,
        -- oi.*,
        o.order_id,
        oi.order_item_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        oi.product_id,
        oi.shipping_limit_date,
        oi.price,
        oi.freight_value
    from sales.fact_orders as o
    left join sales.fact_order_items as oi
        on o.order_id = oi.order_id
    -- where o.order_approved_at is null
    where oi.price is not null
) as sub
-- order by sub.order_purchase_timestamp

-- generate order sales table
select
    d.full_date,
    d.year_number,
    d.quarter_number,
    d.month_number,
    d.month_name_short,
    d.week_number,
    d.day_of_year,
    d.day_of_month,
    d.day_of_week,
    d.day_name,
    sub.price as order_price,
    sub.freight_value as order_freight_value
into #order_sales
from (
    select
        -- o.*,
        -- oi.*,
        o.order_approved_at,
        cast(datetrunc(day, o.order_approved_at) as date) as full_date,
        oi.price,
        oi.freight_value
    from sales.fact_orders as o
    left join sales.fact_order_items as oi
        on o.order_id = oi.order_id
    where oi.price is not null
        and o.order_status in (
            'approved',
            'delivered',
            'invoiced',
            'processing',
            'shipped'
        )
    -- order by o.order_approved_at
) as sub
right join utils.dim_date as d
    on sub.full_date = d.full_date
order by d.full_date;

select * from #order_sales

select * from utils.dim_date

drop table #order_sales

-- GMV year
select
    os.year_number,
    sum(os.order_price)
from #order_sales as os
group by os.year_number
order by os.year_number asc

-- GMV quarter
select
    os.year_number,
    os.quarter_number,
    sum(os.order_price)
from #order_sales as os
group by os.year_number, os.quarter_number
order by os.year_number asc, os.quarter_number asc

-- GMV month
select
    os.year_number,
    os.month_number,
    sum(os.order_price) as GMV_month
from #order_sales as os
group by os.year_number, os.month_number
order by os.year_number asc, os.month_number asc

-- GMV week
select
    os.year_number,
    os.week_number,
    sum(os.order_price) as GMV_week
from #order_sales as os
group by os.year_number, os.week_number
order by os.year_number asc, os.week_number asc

-- GMV day
select
    os.full_date,
    sum(os.order_price)
from #order_sales as os
group by os.full_date
order by os.full_date asc


select * from utils.dim_date







/*

-- products
select distinct
    p.*
from sales.dim_products as p
right join #order_items_in_period as oiip
    on p.product_id = oiip.product_id

-- order payments
select
    op.*
from sales.fact_order_payments as op
right join #orders_in_period as oip
    on op.order_id = oip.order_id

*/

