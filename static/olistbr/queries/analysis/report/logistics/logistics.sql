USE olist;

-- TODO: continue
-- 19015 distinct zip code prefixes
SELECT DISTINCT g.geolocation_zip_code_prefix
FROM logistics.fact_geolocation AS g
ORDER BY g.geolocation_zip_code_prefix ASC

-- find average long lat of each zip code prefix
WITH cte AS (
    SELECT
        g.geolocation_zip_code_prefix,
        COUNT(DISTINCT g.geolocation_lat) AS count_lat,
        COUNT(DISTINCT g.geolocation_lng) AS count_lng,
        AVG(g.geolocation_lat) AS avg_lat,
        AVG(g.geolocation_lng) AS avg_lng
    FROM logistics.fact_geolocation AS g
    GROUP BY g.geolocation_zip_code_prefix
)

SELECT g.*
FROM cte AS g
WHERE g.count_lat != count_lng
ORDER BY g.geolocation_zip_code_prefix

SELECT g.*
FROM logistics.fact_geolocation AS g
WHERE g.geolocation_zip_code_prefix = '01220'


/*
min_lat, max_lat, min_lng, max_lng,
-36.605374, 45.065933, -101.466766, 121.105394

min_lat:
lat, lng
-36.605374, -64.283946
Buenos Aires 147, Villa del Busto, 6300 Santa Rosa, Argentina

max_lat:
lat, lng
45.065933, 9.341528
Via Emilia, 27049 Stradella PV, Italy

min_lng:
lat, lng
21.657547, -101.466766
unnamed road, San Antonio, 37630, GUA, Mexico

max_lng:
lat, lng
14.585073, 121.105394
1st Street, Pasig Second District, Pasig, 1608 Metro Manila, Philippines
*/


SELECT
    MIN(g.geolocation_lat) AS min_lat,
    MAX(g.geolocation_lat) AS max_lat,
    MIN(g.geolocation_lng) AS min_lng,
    MAX(g.geolocation_lng) AS max_lng
FROM logistics.fact_geolocation AS g

-- min lat
SELECT g.*
FROM logistics.fact_geolocation AS g
WHERE g.geolocation_lng = '121.105394'
