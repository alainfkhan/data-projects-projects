USE olist_stg;
/*
can i infer the product category type from the orders its grouped with (in the same basket)
*/


/*
get distinct order_ids for
orders made more than 1 items in the basket
where the product category name is null
*/
-- grouped orders with orders with missing product categories
SELECT
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
FROM sales.fact_orders AS o
LEFT JOIN sales.fact_order_items AS oi
    ON o.order_id = oi.order_id
LEFT JOIN sales.dim_products AS p
    ON oi.product_id = p.product_id
LEFT JOIN sales.dim_product_category_name_translation AS pt
    ON p.product_category_name = pt.product_category_name
WHERE o.order_id IN (
    /*
    order ids that have more than 1 items in basket
    and null product category names on products
    */
    SELECT DISTINCT o.order_id
    FROM sales.fact_orders AS o
    LEFT JOIN sales.fact_order_items AS oi
        ON o.order_id = oi.order_id
    LEFT JOIN sales.dim_products AS p
        ON oi.product_id = p.product_id
    WHERE
        oi.order_item_id > 1
        AND oi.product_id IN (
            -- null product category
            SELECT DISTINCT p.product_id
            FROM sales.dim_products AS p
            WHERE p.product_category_name IS NULL
        )
)
ORDER BY
    o.order_purchase_timestamp,
    oi.order_item_id
