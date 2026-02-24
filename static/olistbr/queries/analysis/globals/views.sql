USE olist_stg;

GO;

/*
sales joins:
    fact_orders
    fact_order_items
    dim_date
*/

CREATE OR ALTER VIEW sales.vw_sales AS
SELECT
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
    CAST(o.order_estimated_delivery_date AS DATE)
        AS order_estimated_delivery_date
FROM sales.fact_orders AS o
LEFT JOIN sales.fact_order_items AS oi
    ON o.order_id = oi.order_id
LEFT JOIN utils.dim_date AS d
    ON CAST(o.order_approved_at AS DATE) = d.full_date
WHERE
    -- a sale occured when:
    o.order_status IN (
        'approved',
        'delivered',
        'invoiced',
        'processing',
        'shipped'
    )
    -- a sale is realised when:
    AND oi.price IS NOT NULL
-- order by o.order_approved_at

GO;

SELECT s.*
FROM sales.vw_sales AS s
ORDER BY s.order_approved_at ASC
