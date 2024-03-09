
{{
    config (
        materialized = 'view'
    )
}}

SELECT 
    *
    , {{ column_dbt_load_datetime() }}  AS {{ var("dbt_prev_month_col_name") }} {# for current data, snapshot date is set to now #}
    
FROM {{ ref('transaction_with_line') }} t