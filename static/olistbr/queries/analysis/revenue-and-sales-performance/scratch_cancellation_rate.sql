use olist_stg;

-- list tables
select
    o.*
from sales.fact_orders as o

select 
    oi.*
from sales.fact_order_items as oi
go;

-- find cancellation rate through time
/*
cancellation is consumer side, so choose date as order_purchase_timestamp
*/
create or alter view sales.vw_cancellation_rate as
select
    subb.*,
    subb.cancelled_count + subb.non_cancelled_count as order_status_count,
    cast(subb.cancelled_count as decimal(9,8)) / nullif(subb.cancelled_count + subb.non_cancelled_count, 0)  as cancellation_rate
from (
    select
        d.full_date,
        sum(case when sub.order_status = 'canceled' then 1 else 0 end) as cancelled_count,
        sum(case when sub.order_status != 'canceled' then 1 else 0 end) as non_cancelled_count
    from (
        select
            o.order_id,
            o.order_purchase_timestamp,
            cast(o.order_purchase_timestamp as date) as order_purchase_date,
            o.order_status
        from sales.fact_orders as o
    ) as sub
    right join utils.dim_date as d
        on sub.order_purchase_date = d.full_date
    group by d.full_date
) as subb

go;
-- order by subb.full_date


-- ==================================================
-- cancellation rate through time
-- ==================================================

select
    d.year_number,
    -- d.quarter_number,
    -- d.month_number,
    d.week_number,
    -- d.full_date,
    sum(cr.cancelled_count) as cancelled_count,
    sum(cr.non_cancelled_count) as non_cancelled_count,
    sum(cr.order_status_count) as order_status_count,
    avg(cr.cancellation_rate) as avg_cancellation_rate
from sales.vw_cancellation_rate as cr
left join utils.dim_date as d
    on cr.full_date = d.full_date
group by
    d.year_number,
    -- d.quarter_number
    -- d.month_number
    d.week_number
    -- d.full_date
order by
    d.year_number,
    -- d.quarter_number
    -- d.month_number
    d.week_number
    -- d.full_date







