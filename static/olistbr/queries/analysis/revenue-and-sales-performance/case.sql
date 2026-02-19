use olist_stg;

/*
-- scratchwork
select top 1000
    o.*
from sales.fact_orders as o;

-- highest order_item_id
select
    sub.order_id,
    sub.order_item_id,
    sub.product_id,
    sub.seller_id,
    sub.shipping_limit_date,
    sub.price,
    sub.freight_value
from (
    select top 1000
        ot.*,
        row_number() over (
            partition by ot.order_id
            order by ot.order_item_id desc
        ) as row_number
    from sales.fact_order_items as ot
    where ot.order_item_id > 1
    order by ot.order_item_id desc
) as sub
where sub.row_number = 1

select
    ot.*
from sales.fact_order_items as ot
where ot.order_id = '8272b63d03f5f79c56e9e4120aec44ef'
*/

-- =========================================
-- Choose initial values
-- =========================================

-- choose any order_id
declare @order_id char(32)
-- choose random
-- set @order_id = '00010242fe8c5a6d1ba2dd792cb16214'
-- set @order_id = '0010dedd556712d7bb69a19cb7bbd37a'
-- set @order_id = '000e906b789b55f64edcb1f84030f90d'
-- set @order_id = '0009c9a17f916a706d71784483a5d643'



-- most order_item_id = 21
-- set @order_id = '8272b63d03f5f79c56e9e4120aec44ef'
-- order_item_id max = 20
-- set @order_id = 'ab14fdcfbe524636d65ee38360e22ce8'
-- order_item_id max = 9
-- set @order_id = 'f5aa338a071dcf7d23d8e6b116bfcab5'
-- order_item_id max = 7
-- set @order_id = '7d316b369d4c6b0a4ebeebbff5f65466'
-- order_item_id max = 5, 4 product_ids
set @order_id = 'cb8a63e70a7f664281f701b6abd79fe5'

-- if multiple product_ids choose which
declare @choose_product_id tinyint = 1

-- =========================================
-- =========================================


-- orders
select top 1000
    o.*
from sales.fact_orders as o
where o.order_id = @order_id

-- customers
declare @customer_id char(32) = (
    select
        o.customer_id
    from sales.fact_orders as o
    where o.order_id = @order_id
)

select
    c.*
from sales.dim_customers as c
where c.customer_id = @customer_id


-- order_items
select top 1000
    ot.*
from sales.fact_order_items as ot
where ot.order_id = @order_id

-- get unique product_ids 
select distinct
    sub.product_id as product_ids
from (
    select top 1000
        ot.*
    from sales.fact_order_items as ot
    where ot.order_id = @order_id
) as sub

declare @product_id char(32)
-- choose row for 1 product id. default 1
set @product_id = (

    select
        choose.product_id
    from (
        
        select
            distinct_product_ids.product_id,
            row_number () over (
                order by distinct_product_ids.product_id
            ) as choose_row
        from (
            select distinct
                repeat_orders.product_id
            from (
                select top 1000
                    oi.*
                from sales.fact_order_items as oi
                where oi.order_id = @order_id
                -- where oi.order_id = '8272b63d03f5f79c56e9e4120aec44ef'
            ) as repeat_orders
        ) as distinct_product_ids

    ) as choose
    where choose.choose_row = @choose_product_id

)

/*
-- if one product_id
set @product_id = (
    select top 1000
        ot.product_id
    from sales.fact_order_items as ot
    where ot.order_id = @order_id
)
*/

-- order_payments
select top 1000
    op.*
from sales.fact_order_payments as op
where op.order_id = @order_id

-- products
select top 1000
    p.*
from sales.dim_products as p
where p.product_id = @product_id

declare @product_category_name varchar(50)
set @product_category_name = (
    select top 1000
        p.product_category_name
    from sales.dim_products as p
    where p.product_id = @product_id
)

print @product_category_name

-- translation
select
    t.product_category_name_english
from sales.dim_product_category_name_translation as t
where t.product_category_name = @product_category_name
-- where t.product_category_name = 'automotivo'
-- where t.product_category_name = 'beleza_saude'



