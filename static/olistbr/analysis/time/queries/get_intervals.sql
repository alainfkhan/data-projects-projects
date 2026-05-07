use olist;

select
    -- o.*,
    -- op.*
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    pt.product_category_name_english,
    c.customer_state,
    m.seller_state,
    o.price,
    o.freight_value,
    op.payment_type,
    op.payment_value,
    o.order_estimated_delivery_date
from sales.vw_orders_practical as o
    left join sales.fact_order_payments as op
        on o.order_id = op.order_id
    left join sales.dim_customers as c
        on o.customer_id = c.customer_id
    left join sales.dim_products as p
        on o.product_id = p.product_id
    left join sales.dim_product_category_name_translation as pt
        on p.product_category_name = pt.product_category_name
    left join sales.dim_sellers as m
        on o.seller_id = m.seller_id
order by
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date;

-- add seller date
/*
find variables that affect estimated delivery date
*/

select
    g.*
from logistics.fact_geolocation as g;

select cep.*
from logistics.dim_cep as cep;
