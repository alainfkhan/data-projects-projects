USE olist_stg;

go;

create or alter view sales.vw_sales as 
select
    d.*,
    o.order_id,
    oi.order_item_id,
    oi.product_id,
    o.customer_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    oi.shipping_limit_date,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    cast(o.order_estimated_delivery_date as date) as order_estimated_delivery_date
from sales.fact_orders as o
left join sales.fact_order_items as oi
    on o.order_id = oi.order_id
right join utils.dim_date as d
    on cast(o.order_approved_at as date) = d.full_date
where
    -- a sale occured when:
    o.order_status in (
        'approved',
        'delivered',
        'invoiced',
        'processing',
        'shipped'
    )
    -- a sale is realised when:
    and oi.price is not null
-- order by o.order_approved_at

go;
