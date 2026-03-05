USE olist;

-- TODO: continue
-- 19015 distinct zip code prefixes
SELECT DISTINCT g.geolocation_zip_code_prefix
FROM logistics.fact_geolocation AS g
ORDER BY g.geolocation_zip_code_prefix ASC

-- find average long lat of each zip code prefix
SELECT
    g.geolocation_zip_code_prefix,
    g.geolocation_lat,
    g.geolocation_lng
FROM logistics.fact_geolocation AS g
ORDER BY g.geolocation_zip_code_prefix ASC
