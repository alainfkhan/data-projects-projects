use olist_stg;
/*
can i infer the product category type from the orders its grouped with (in the same basket)
*/


/*
get distinct order_ids for
orders made more than 1 items in the basket
where the product category name is null
*/
-- grouped orders with orders with missing product categories
select
    o.order_purchase_timestamp,
    o.order_id,
    oi.order_item_id,
    o.order_status,
    p.product_id,
    pt.product_category_name_english,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    oi.price,
    oi.freight_value
from sales.fact_orders as o
left join sales.fact_order_items as oi
    on o.order_id = oi.order_id
left join sales.dim_products as p
    on oi.product_id = p.product_id
left join sales.dim_product_category_name_translation as pt
    on p.product_category_name = pt.product_category_name
where o.order_id in (
    /*
    order ids that have more than 1 items in basket
    and null product category names on products
    */
    select distinct o.order_id
    from sales.fact_orders as o
    left join sales.fact_order_items as oi
        on o.order_id = oi.order_id
    left join sales.dim_products as p
        on oi.product_id = p.product_id
    where
        oi.order_item_id > 1
        and oi.product_id in (
            -- null product category
            select distinct p.product_id
            from sales.dim_products as p
            where p.product_category_name is null
        )
)
order by
    o.order_purchase_timestamp,
    oi.order_item_id