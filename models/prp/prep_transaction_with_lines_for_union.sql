
{{
    config (
        materialized = 'view'
    )
}}

SELECT 
    *
    , {{ column_dbt_load_datetime() }}  AS {{ var("dbt_prev_month_col_name") }}
    
FROM {{ ref('prep_transaction_with_lines') }} t