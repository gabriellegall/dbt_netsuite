{{
    config (
        materialized = 'view'
    )
}}

WITH fx_avg_unpivot AS 
(
    {{
        dbt_utils.unpivot (
            relation = ref("fx_avg_rate"),
            cast_to = "float",
            exclude = ['original_currency','target_currency'],
            field_name = "closing_date",
            value_name = "fx_rate_original_to_target"
        )
    }}
)

SELECT 
        original_currency
        , target_currency
        , closing_date
        , fx_rate_original_to_target
FROM fx_avg_unpivot
WHERE target_currency = 'USD'

UNION ALL

SELECT 
        'USD'               AS original_currency
        , 'USD'             AS target_currency
        , closing_date
        , 1                 AS fx_rate_original_to_target
FROM fx_avg_unpivot
GROUP BY closing_date