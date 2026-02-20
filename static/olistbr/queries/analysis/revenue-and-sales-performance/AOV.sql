use olist_stg;

-- get obt order sales
select 
    d.*,
    sub.*
into #order_sales
from (

    select
        -- o.*,
        -- oi.*
        o.order_id,
        oi.order_item_id,
        o.order_status,
        -- o.order_purchase_timestamp,
        o.order_approved_at,
        cast(datetrunc(day, o.order_approved_at) as date) as order_purchase_date,
        convert(time, o.order_approved_at) as order_purchase_time,
        oi.price as order_price,
        oi.freight_value as order_freight_value
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
        -- and o.order_id = '8272b63d03f5f79c56e9e4120aec44ef'
        -- and oi.order_item_id = 21

) as sub
right join utils.dim_date as d
    on sub.order_purchase_date = d.full_date
order by d.full_date;

drop table #order_sales

-- find distinct order statuses
select distinct
    o.order_status
from sales.fact_orders as o

/*
approved
delivered
created
invoiced
processing
unavailable
canceled
shipped
*/

-- AOV year
select
    os.year_number as [year],
    sum(os.order_price) as total_revenue,
    count(distinct os.order_id) as total_distinct_orders,
    sum(os.order_price)/count(distinct os.order_id) as AOV
from #order_sales as os
group by os.year_number
order by os.year_number

-- AOV quarter
select
    -- os.year_number,
    -- os.quarter_number,
    concat(
        'FY', right(os.year_number, 2), ' Q', os.quarter_number
    ) as quarter,
    sum(os.order_price) as total_revenue,
    count(distinct os.order_id) as total_distinct_orders,
    sum(os.order_price)/count(distinct os.order_id) as AOV_per_quarter
from #order_sales as os
group by os.year_number, os.quarter_number
order by os.year_number, os.quarter_number


-- AOV month
select
    -- os.year_number as [year],
    concat(
        format(datefromparts(1900, os.month_number, 1), 'MMM'),
        ' ',
        os.year_number
    ) as [month],
    sum(os.order_price) as total_revenue,
    count(distinct os.order_id) as total_distinct_orders,
    sum(os.order_price)/count(distinct os.order_id) as AOV_per_month
from #order_sales as os
group by os.year_number, os.month_number
order by os.year_number, os.month_number



-- AOV week
-- want to say week comencing
-- YYwWW
select
    -- os.year_number,
    -- os.week_number,
    concat(
        right(os.year_number, 2),
        'w',
        format(os.week_number, '00')
    ) as [week],
    sum(os.order_price) as total_revenue,
    count(distinct os.order_id) as total_distinct_orders,
    sum(os.order_price)/count(distinct os.order_id) as AOV
from #order_sales as os
group by os.year_number, os.week_number
order by os.year_number, os.week_number


-- AOV day
select
    os.year_number,
    os.day_of_year,
    sum(os.order_price) as total_revenue,
    count(distinct os.order_id) as total_distinct_orders,
    sum(os.order_price)/count(distinct os.order_id) as AOV_per_day
from #order_sales as os
group by os.year_number, os.day_of_year
order by os.year_number, os.day_of_year


