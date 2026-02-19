USE olist_stg;

-- complemento had converter type str meaning any nulls = ''
-- need to change all '' to null
SELECT top 1000 *
FROM logistics.dim_cep AS c
WHERE c.COMPLEMENTO is not NULL;

SELECT
    c.*
FROM logistics.dim_cep AS c
WHERE c.CEP LIKE '31170%';

SELECT TOP 1 g.*
FROM logistics.fact_geolocation AS g
ORDER BY NEWID()

SELECT TOP 1000 s.*
FROM sales.dim_sellers AS s
