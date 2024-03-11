{{
    config (
        materialized = 'view'
    )
}}


{# TO DO : Make the joins inside this layer instead of the previous one, this way you can retrieve all columns dynamically from the previous layer #}

SELECT 
    {{ dbt_utils.star(from=ref('transaction_with_line')) }}
    , CASE WHEN t.transaction_type IN ('Opportunity', 'Sales Order') THEN t.expected_delivery_date ELSE t.transaction_date END AS calculation_date
    , {{ dbt_utils.star(from=ref('dim_item')    , except = var("scd_excluded_col_name") ) }}
    , {{ dbt_utils.star(from=ref('dim_bu')      , except = var("scd_excluded_col_name") ) }}
    , {{ dbt_utils.star(from=ref('dim_customer'), except = var("scd_excluded_col_name") ) }}

FROM {{ ref("fact_all_transactions_with_line") }} t

{# Scope of the dataset #}
WHERE t.transaction_type IN ( {{ var("sales_scope_type") | join(', ') }} )