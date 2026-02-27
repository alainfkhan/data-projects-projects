use olist_stg;

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

begin transaction t


if (
    select pt.product_category_name
    from sales.dim_product_category_name_translation as pt
    where pt.product_category_name = 'pc_gamer'
) is null
begin
    insert into sales.dim_product_category_name_translation
        (product_category_name, product_category_name_english)
    values
        ('pc_gamer', 'pc_gamer')
end;


if (
    select pt.product_category_name
    from sales.dim_product_category_name_translation as pt
    where pt.product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos'
) is null
begin
    insert into sales.dim_product_category_name_translation
        (product_category_name, product_category_name_english)
    values
        ('portateis_cozinha_e_preparadores_de_alimentos', 'small_appliances_kitchen_and_food_preparation')
end;

/*
commit transaction
*/