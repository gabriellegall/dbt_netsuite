{{
    config (
        materialized = 'view'
    )
}}

WITH flag_latest_rate AS 
(
    SELECT 
        *     
        , ROW_NUMBER () OVER (PARTITION BY original_currency ORDER BY closing_date DESC) AS row_id
    FROM {{ ref("prep_fx_avg_rate_unpivot") }}
),

filter_latest_rate AS 
(
    SELECT
        *
    FROM flag_latest_rate 
    WHERE row_id = 1
)

SELECT
    t1.original_currency
    , t1.fx_rate_original_to_target                                 AS fx_rate_original_to_usd
    , t1.fx_rate_original_to_target / t2.fx_rate_original_to_target AS fx_rate_original_to_dynamic
    , '{{ var("fx_avg_implicit_currency") }}'                       AS dynamic_target_currency
FROM
    filter_latest_rate t1
CROSS JOIN 
    (SELECT fx_rate_original_to_target FROM filter_latest_rate WHERE original_currency = '{{ var("fx_avg_implicit_currency") }}' ) t2