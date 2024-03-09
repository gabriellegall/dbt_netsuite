{{
    config (
        materialized        = 'incremental'    
        , on_schema_change  = 'append_new_columns'
        , full_refresh      = false
    )
}}

SELECT
    {{ dbt_utils.star(from=ref('transaction_with_line'), except=[var("dbt_run_id_col_name"), var("dbt_load_datetime_col_name")]) }}
    , {{ column_dbt_previous_month() }} AS {{ var("dbt_prev_month_col_name") }}
    , {{ column_dbt_load_datetime() }}  AS {{ var("dbt_load_datetime_col_name") }}
    , '{{ var("dbt_run_id") }}'         AS {{ var("dbt_run_id_col_name") }}

FROM {{ ref('transaction_with_line') }} t

{% if is_incremental() %}
        {# Checks if a snapshot has been made #}
    WHERE {{ column_dbt_previous_month() }} >= ( SELECT MAX ( incremental_date.{{ var("dbt_prev_month_col_name") }} ) FROM {{ this }} as incremental_date )
{% endif %}