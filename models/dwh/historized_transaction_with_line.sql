{{
    config (
        materialized    = 'incremental'    
        , full_refresh  = false
        , on_schema_change = 'append_new_columns'
    )
}}

SELECT
    *
    , {{ column_dbt_previous_month() }} AS {{ var("dbt_prev_month_col_name") }}
    , {{ column_dbt_load_datetime() }}  AS {{ var("dbt_load_datetime_col_name") }}

FROM {{ ref('transaction_with_line') }} t

{% if is_incremental() %}
    WHERE {{ column_dbt_previous_month() }} > ( SELECT MAX ( incremental_date.{{ var("dbt_prev_month_col_name") }} ) FROM {{ this }} as incremental_date);
{% endif %}