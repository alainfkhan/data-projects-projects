USE olist_stg;

WITH sym_diff AS (
    SELECT DISTINCT
        mql.mql_id AS mql_mql_id,
        cd.mql_id AS cd_mql_id
    FROM marketing.fact_marketing_qualified_leads AS mql
        LEFT JOIN marketing.fact_closed_deals AS cd
            ON mql.mql_id = cd.mql_id
    WHERE
        mql.mql_id IS NULL
        OR cd.mql_id IS NULL
)

SELECT
    COUNT(DISTINCT s.mql_mql_id) AS unique_mql_mql_ids,
    COUNT(DISTINCT s.cd_mql_id) AS unique_cd_mql_ids
FROM sym_diff AS s

/*
7158 unique mql_ids exist in marketing_qualifed_leads but not in closed_deals
*/
