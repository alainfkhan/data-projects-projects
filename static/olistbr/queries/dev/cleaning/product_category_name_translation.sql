USE olist;

/*
distinct product_category_names in table products
not 1-1 with product_category_names in product_category_name_translation

product_category_name, product_category_name, product_category_name_english
pc_gamer, NULL, NULL
portateis_cozinha_e_preparadores_de_alimentos, NULL, NULL
*/

/*

-- show missed mappings
select
    distinct p.product_category_name,
    pt.*
from sales.dim_products as p
left join sales.dim_product_category_name_translation as pt
    on p.product_category_name = pt.product_category_name
order by p.product_category_name

rollback transaction t

*/

BEGIN TRANSACTION t


IF (
    SELECT pt.product_category_name
    FROM sales.dim_product_category_name_translation AS pt
    WHERE pt.product_category_name = 'pc_gamer'
) IS NULL
BEGIN
    INSERT INTO sales.dim_product_category_name_translation
        (product_category_name, product_category_name_english)
    VALUES
        ('pc_gamer', 'pc_gamer')
END;


IF (
    SELECT pt.product_category_name
    FROM sales.dim_product_category_name_translation AS pt
    WHERE
        pt.product_category_name
        = 'portateis_cozinha_e_preparadores_de_alimentos'
) IS NULL
BEGIN
    INSERT INTO sales.dim_product_category_name_translation
        (product_category_name, product_category_name_english)
    VALUES
        (
            'portateis_cozinha_e_preparadores_de_alimentos',
            'small_appliances_kitchen_and_food_preparation'
        )
END;

/*
commit transaction t
*/
