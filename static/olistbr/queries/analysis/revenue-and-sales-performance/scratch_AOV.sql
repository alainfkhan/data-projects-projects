use olist_stg;

-- redo
-- join relevant tables, filter, aggregate revenue, join date
select
    d.*,
    sub.*
into #order_revenue
from (
    select
        -- o.*,
        -- oi.*
        -- cast(o.order_purchase_timestamp as date) as order_purchase_date,
        cast(o.order_approved_at as date) as order_approved_date,
        sum(oi.price) as total_product_revenue,
        sum(oi.freight_value) as total_freight_revenue,
        count(distinct o.order_id) as order_count
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
    -- group by cast(o.order_purchase_timestamp as date)
    group by cast(o.order_approved_at as date)
) as sub
right join utils.dim_date as d
    on sub.order_approved_date = d.full_date
order by d.date_key

/*
drop table #order_revenue
*/

-- verify distinct count
select
    count(distinct o.order_id)
from sales.fact_orders as o
where cast(o.order_approved_at as date) = '2018-04-18'
-- 275 (correct)

-- 293 distinct sales in 2016 (correct)
-- 44304 distinct sales in 2017 (correct)
-- 53588 disintct sales in 2018 (correct)
select
    -- o.*
    count(distinct o.order_id)
from sales.fact_orders as o
left join sales.fact_order_items as oi
    on o.order_id = oi.order_id
where datepart(year, o.order_approved_at) = '2018'
    and oi.price is not null
    and o.order_status in (
        'approved',
        'delivered',
        'invoiced',
        'processing',
        'shipped'
    )

-- view created table
select *
from #order_revenue as r
order by r.date_key

-- ==================================================
-- NEW ATTEMPT
-- same result as old attempt, better intelisense
-- filter, aggregate, aggregate at query
-- aggregation happens twice
-- smallest grain defined at table creation, less versitile
-- ==================================================

-- AOV

-- year
select
    sub.*,
    sub.year_product_revenue/sub.year_order_count as AOV,
    sub.year_freight_revenue/sub.year_order_count as avg_shipping_income,
    sub.year_freight_revenue/sub.year_product_revenue as freight_to_product_ratio,
    sub.year_product_revenue+sub.year_freight_revenue as total_revenue
from (
    select
        -- r.*,
        r.year_number,
        -- r.total_product_revenue,
        -- r.total_freight_revenue
        sum(r.total_product_revenue) as year_product_revenue,
        sum(r.total_freight_revenue) as year_freight_revenue,
        sum(r.order_count) as year_order_count
    from #order_revenue as r
    group by r.year_number
) as sub
order by sub.year_number

-- quarter
select
    r.year_number,
    r.quarter_number,
    sum(r.total_product_revenue) as quarter_product_revenue,
    sum(r.total_freight_revenue) as quarter_freight_revenue,
    sum(r.order_count) as quarter_order_count
from #order_revenue as r
group by r.year_number, r.quarter_number
order by r.year_number, r.quarter_number

-- month
select
    r.year_number,
    r.month_number,
    sum(r.total_product_revenue) as month_product_revenue,
    sum(r.total_freight_revenue) as month_freight_revenue,
    sum(r.order_count) as month_order_count
from #order_revenue as r
group by r.year_number, r.month_number
order by r.year_number, r.month_number

-- week
select
    r.year_number,
    r.week_number,
    sum(r.total_product_revenue) as week_product_revenue,
    sum(r.total_freight_revenue) as week_freight_revenue,
    sum(r.order_count) as week_order_count
from #order_revenue as r
group by r.year_number, r.week_number
order by r.year_number, r.week_number

-- day
select
    r.year_number,
    r.day_of_year,
    sum(r.total_product_revenue) as day_product_revenue,
    sum(r.total_freight_revenue) as day_freight_revenue,
    sum(r.order_count) as day_order_count
from #order_revenue as r
group by r.year_number, r.day_of_year
order by r.year_number, r.day_of_year

-- ==================================================
-- OLD ATTEMPT
-- same result as new attempt
-- filter, aggregate at query
-- more versitile, option to change grain at query
-- ==================================================

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
    -- order by o.order_approved_at
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

select *
from #order_sales as os
order by os.full_date

-- AOV year
select
    os.year_number as [year],
    sum(os.order_price) as year_product_revenue,
    sum(os.order_freight_value) as year_freight_revenue,
    sum(os.order_price + os.order_freight_value) as year_gross_revenue,
    count(distinct os.order_id) as year_order_count,
    sum(os.order_price)/count(distinct os.order_id) as something
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
    -- datetrunc(week, os.full_date) as full_date,
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


