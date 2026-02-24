USE olist_stg;


-- list tables
SELECT sa.*
FROM sales.vw_sales AS sa

SELECT se.*
FROM sales.dim_sellers AS se

SELECT cd.*
FROM marketing.fact_closed_deals AS cd

-- ==================================================
-- revenue by business segment through time
-- ==================================================

SELECT
    sa.year_number,
    sa.week_number,
    cd.business_segment,
    COUNT(DISTINCT sa.order_id) AS order_count,
    SUM(sa.price) AS total_product_revenue,
    SUM(sa.freight_value) AS total_freight_revenue
FROM sales.vw_sales AS sa
LEFT JOIN sales.dim_sellers AS se
    ON sa.seller_id = se.seller_id
LEFT JOIN marketing.fact_closed_deals AS cd
    ON se.seller_id = cd.seller_id
WHERE
    cd.mql_id IS NOT NULL
    AND cd.business_segment = 'computers'
GROUP BY
    sa.year_number,
    sa.week_number,
    cd.business_segment
ORDER BY
    sa.year_number,
    sa.week_number,
    cd.business_segment


-- quick analysis
-- unique business segments
SELECT DISTINCT cd.business_segment
FROM marketing.fact_closed_deals AS cd
ORDER BY cd.business_segment ASC
/*
NULL
air_conditioning
audio_video_electronics
baby
bags_backpacks
bed_bath_table
books
car_accessories
computers
construction_tools_house_garden
fashion_accessories
food_drink
food_supplement
games_consoles
gifts
handcrafted
health_beauty
home_appliances
home_decor
home_office_furniture
household_utilities
jewerly
music_instruments
other
party
perfume
pet
phone_mobile
religious
small_appliances
sports_leisure
stationery
toys
watches
*/
