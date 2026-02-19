use olist_stg

-- find GMV over a period
-- [)
declare @start_date datetime2 = '2018-01-01'
declare @end_date datetime2 = '2019-01-01'

/*
*/

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
-- TODO: find MoM and YoY queries
-- GMV MoM
select
    o.*
from sales.fact_orders as o
where o.order_approved_at is not null
order by
    o.order_approved_at

-- GMV YoY



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


