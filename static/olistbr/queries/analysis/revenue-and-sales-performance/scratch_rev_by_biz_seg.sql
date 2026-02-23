use olist_stg;


-- list tables
select
    sa.*
from sales.vw_sales as sa

select
    se.*
from sales.dim_sellers as se

select
    cd.*
from marketing.fact_closed_deals as cd

-- ==================================================
-- revenue by business segment through time
-- ==================================================

select 
    sa.year_number,
    sa.week_number,
    cd.business_segment,
    count(distinct sa.order_id) as order_count,
    sum(sa.price) as total_product_revenue,
    sum(sa.freight_value) as total_freight_revenue
from sales.vw_sales as sa
left join sales.dim_sellers as se
    on sa.seller_id = se.seller_id
left join marketing.fact_closed_deals as cd
    on se.seller_id = cd.seller_id
where
    cd.mql_id is not null
    and cd.business_segment = 'computers'
group by
    sa.year_number,
    sa.week_number,
    cd.business_segment
order by
    sa.year_number,
    sa.week_number,
    cd.business_segment


-- quick analysis
-- unique business segments
select distinct
    cd.business_segment
from marketing.fact_closed_deals as cd
order by cd.business_segment asc
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