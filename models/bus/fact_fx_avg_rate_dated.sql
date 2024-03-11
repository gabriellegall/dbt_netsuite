{{
    config (
        materialized = 'view'
    )
}}

SELECT
    t1.original_currency
    , t1.closing_date
    , t1.fx_rate_original_to_target                                 AS fx_rate_original_to_usd
    , t1.fx_rate_original_to_target / t2.fx_rate_original_to_target AS fx_rate_original_to_dynamic
    , '{{ var("fx_avg_implicit_currency") }}'                       AS dynamic_target_currency
FROM
    {{ ref("prep_fx_avg_rate_unpivot") }} t1
LEFT OUTER JOIN 
    (SELECT fx_rate_original_to_target, closing_date FROM {{ ref("prep_fx_avg_rate_unpivot") }} WHERE original_currency = '{{ var("fx_avg_implicit_currency") }}' ) t2 ON t1.closing_date = t2.closing_date