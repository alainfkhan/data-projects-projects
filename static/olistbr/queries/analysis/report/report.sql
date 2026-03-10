USE olist;
-- scratchwork

SELECT oi.*
FROM sales.fact_order_items AS oi

SELECT DISTINCT o.order_status
FROM sales.fact_orders AS o
ORDER BY o.order_status

select
    oi.*
from sales.fact_order_items as oi
where
    oi.price is null
    -- and oi.freight_value is null

select 
    o.*,
    oi.*
    -- o.order_status
from sales.fact_orders as o
    right join sales.fact_order_items as oi
        on o.order_id = oi.order_id
where o.order_status in ('unavailable', 'canceled')

/*
approved
delivered
invoiced
processing
unavailable
canceled
shipped
*/
