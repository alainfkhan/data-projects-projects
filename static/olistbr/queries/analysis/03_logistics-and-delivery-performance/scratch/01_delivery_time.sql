use olist_stg;


-- ==================================================
-- average delivery time?
-- ==================================================

select
    sub.*,
    1.0 * sub.avg_purchase_to_customer_duration_s / 86400 as avg_purchase_to_customer_duration_days,
    utils.fn_seconds_to_ddhhmmss(sub.avg_purchase_to_customer_duration_s) as avg_purchase_to_customer_duration_format
from (
    select
        -- sub.*
        d.year_number,
        d.week_number,
        count(distinct sub.order_id) as order_count,
        avg(sub.purchase_to_customer_duration_s) as avg_purchase_to_customer_duration_s
    from (
        select
            d.*,
            o.*,
            datediff_big(second, o.order_purchase_timestamp, o.order_delivered_customer_date) as purchase_to_customer_duration_s
        from sales.fact_orders as o
        left join utils.dim_date as d
            on cast(o.order_purchase_timestamp as date) = d.key_date
        -- that are sales
        where o.order_id in (
            select distinct s.order_id
            from sales.vw_sales as s)
    ) as sub
    right join utils.dim_date as d
        on sub.date_key = d.date_key
    group by 
        d.year_number,
        d.week_number
) as sub
order by 
    sub.year_number,
    sub.week_number

/*
that are sales:
2016	9	4735860	54 days 19:31:00
2016	10	1693488	19 days 14:24:48
2016	11	NULL	NULL
2016	12	405477	4 days 16:37:57
2017	1	1092704	12 days 15:31:44
2017	2	1137786	13 days 04:03:06
2017	3	1118982	12 days 22:49:42
2017	4	1288907	14 days 22:01:47
2017	5	978252	11 days 07:44:12
2017	6	1037799	12 days 00:16:39
2017	7	1001612	11 days 14:13:32
2017	8	963111	11 days 03:31:51
2017	9	1023926	11 days 20:25:26
2017	10	1024418	11 days 20:33:38
2017	11	1309921	15 days 03:52:01
2017	12	1330120	15 days 09:28:40
2018	1	1216560	14 days 01:56:00
2018	2	1464059	16 days 22:40:59
2018	3	1408441	16 days 07:14:01
2018	4	993534	11 days 11:58:54
2018	5	986604	11 days 10:03:24
2018	6	798268	9 days 05:44:28
2018	7	774026	8 days 23:00:26
2018	8	668112	7 days 17:35:12
*/

/*
want to look at cols:
    date column is null:
        distinct order_statuses
    order_purchase_timestamp is never null
    order_approved_at is null:
        canceled
        created
        delivered
    order_delivered_carrier_date is null:
        approved
        canceled
        created
        delivered
        invoiced
        processing
        unavailable
    order_delivered_customer_date is null
        approved
        canceled
        created
        delivered
        invoiced
        processing
        shipped
        unavailable
    order_estimated_delivery_date is never null
*/

select
    -- o.*,
    -- oi.*
    distinct o.order_status
from sales.fact_orders as o
left join sales.fact_order_items as oi
    on o.order_id = oi.order_id
where
    -- o.order_purchase_timestamp is null
    -- o.order_approved_at is null
    -- o.order_delivered_carrier_date is null
    -- o.order_delivered_customer_date is null
    o.order_estimated_delivery_date is null
order by o.order_status


-- ==================================================
-- % of late deliveries?
-- ==================================================
/*
delivered customer and estimated dates must exist

define is late delivery delivered on the full date beyond estimated
is late delivery if difference from delivered to estmiate is more than one day
tolerance is 1 day = 86400 seconds
eg:
order_id                            order_delivered_customer_date   order_estimated_delivery_date   diff_s  is_late_delivery
1800e46c3912d9882187335b9768b6a9	2018-08-13 23:58:35.0000000	    2018-08-13 00:00:00.0000000	    -86315	0
8f0033d3ef07e82e7e942e4136cfbf50	2018-08-29 00:03:16.0000000	    2018-08-28 00:00:00.0000000	    -86596	1

is_delivered_before_estimated_date if arrives 1 or more days before estimated date
is_delivered_on_estimated_date if arrives on estimated date
is_delivered_after_estimated_date if arrives 1 or more days after estimated date

*/

select
    -- o.*,
    o.order_id,
    -- o.order_delivered_customer_date,
    -- o.order_estimated_delivery_date,
    o.lateness_s,
    -- utils.fn_seconds_to_ddhhmmss(o.lateness_s) as lateness_format_duration,
    case
        when cast(o.order_delivered_customer_date as date) < cast(o.order_estimated_delivery_date as date)
            then 'early'
        when cast(o.order_delivered_customer_date as date) = cast(o.order_estimated_delivery_date as date)
            then 'on_time'
        when cast(o.order_delivered_customer_date as date) > cast(o.order_estimated_delivery_date as date)
            then 'late'
            else 'unkown'
    end as delivery_status
    -- case
    --     when o.order_delivered_customer_date is null or o.order_estimated_delivery_date is null
    --         then null
    --     when cast(o.order_delivered_customer_date as date) < cast(o.order_estimated_delivery_date as date)
    --         then 1
    --         else 0
    -- end as is_delivered_early,
    -- case
    --     when o.order_delivered_customer_date is null or o.order_estimated_delivery_date is null
    --         then null
    --     when cast(o.order_delivered_customer_date as date) = cast(o.order_estimated_delivery_date as date)
    --         then 1
    --         else 0
    -- end as is_delivered_on_estimated_date,
    -- case
    --     when o.order_delivered_customer_date is null or o.order_estimated_delivery_date is null
    --         then null
    --     when cast(o.order_delivered_customer_date as date) > cast(o.order_estimated_delivery_date as date)
    --         then 1
    --         else 0
    -- end as is_delivered_late
into #delivery_lateness
from (
    select
        -- o.order_id,
        -- o.order_delivered_customer_date,
        -- o.order_estimated_delivery_date,
        o.*,
        - datediff_big(second, o.order_delivered_customer_date, o.order_estimated_delivery_date) as lateness_s
    from sales.fact_orders as o
    -- where
    --     o.order_delivered_customer_date is not null
    --     and o.order_estimated_delivery_date is not null
) as o
order by o.order_purchase_timestamp

drop table #delivery_lateness

select
    d.*,
    1.0 * d.early_deliveries / nullif(d.total_deliveries, 0) as pc_early_deliveries,
    1.0 * d.on_time_deliveries / nullif(d.total_deliveries, 0) as pc_on_time_deliveries,
    1.0 * d.late_deliveries / nullif(d.total_deliveries, 0) as pc_late_deliveries,
    1.0 * (d.early_deliveries + d.on_time_deliveries) / nullif(d.total_deliveries, 0) as pc_not_late_deliveries
from (
    select
        d.year_number,
        d.month_number,
        sum(case when l.delivery_status = 'early'
            then 1
            else 0
        end) as early_deliveries,
        sum(case when l.delivery_status = 'on_time'
            then 1
            else 0
        end) as on_time_deliveries,
        sum(case when l.delivery_status = 'late'
            then 1
            else 0
        end) as late_deliveries,
        sum(case when l.delivery_status in ('early', 'on_time', 'late')
            then 1
            else 0
        end) as total_deliveries
    from (
        select
            o.order_id,
            o.order_status,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date,
            o.order_estimated_delivery_date,
            l.lateness_s,
            l.delivery_status,
            oi.price,
            oi.freight_value
        from sales.fact_orders as o
        left join sales.fact_order_items as oi
            on o.order_id = oi.order_id
        left join #delivery_lateness as l
            on o.order_id = l.order_id
    ) as l
    right join utils.dim_date as d
        on cast(l.order_purchase_timestamp as date) = d.key_date
    group by 
        d.year_number,
        d.month_number
) as d
order by 
    d.year_number,
    d.month_number

-- analysis

-- 96476
select distinct o.order_id
from sales.fact_orders as o
where o.order_delivered_customer_date is not null

select
    o.*
from sales.fact_orders as o
where o.order_delivered_customer_date is null

-- 98199
select distinct o.order_id
from sales.fact_orders as o
left join sales.fact_order_items as oi
    on o.order_id = oi.order_id
WHERE
    o.order_status IN (
        'approved',
        'delivered',
        'invoiced',
        'processing',
        'shipped'
    )
    and oi.price is not null


select
    o.*
from sales.fact_orders as o

-- ==================================================
-- delivery time by state?
-- ==================================================

select
    -- sub.*
    d.year_number,
    d.month_number,
    sub.customer_state,
    count(distinct sub.order_id) as order_count,
    -- avg(sub.purchase_to_customer_duration_s) as avg_purchase_to_customer_duration_s,
    utils.fn_seconds_to_ddhhmmss(avg(sub.purchase_to_customer_duration_s)) as avg_purchase_to_customer_duration_format,
    avg(sub.freight_value) as avg_freight_revenue
from (
    select
        -- o.*,
        -- c.*
        o.order_id,
        c.customer_state,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        datediff_big(second, o.order_purchase_timestamp, o.order_delivered_customer_date) as purchase_to_customer_duration_s,
        oi.price,
        oi.freight_value
    from sales.fact_orders as o
    left join sales.fact_order_items as oi
        on o.order_id = oi.order_id
    left join sales.dim_customers as c
        on o.customer_id = c.customer_id
) as sub
right join utils.dim_date as d
    on cast(sub.order_purchase_timestamp as date) = d.key_date
group by 
    d.year_number,
    d.month_number,
    sub.customer_state
order by 
    d.year_number,
    d.month_number,
    sub.customer_state



-- freight cost vs distance?
-- does delivery time affect review score?