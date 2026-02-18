USE olist_stg;

-- complemento had converter type str meaning any nulls = ''
-- need to change all '' to null
SELECT *
FROM logistics.dim_cep_iz_AuBmA AS c
WHERE c.COMPLEMENTO != '';

SELECT TOP 1000 c.*
FROM logistics.dim_cep_iz_AuBmA AS c
WHERE c.CEP LIKE '89600%';

SELECT TOP 1 g.*
FROM logistics.fact_geolocation AS g
ORDER BY NEWID()

SELECT TOP 1000 s.*
FROM sales.dim_sellers AS s
