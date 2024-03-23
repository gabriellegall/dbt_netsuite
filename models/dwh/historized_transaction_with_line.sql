{# Don't forget to set it back to false #}
{{
    config (
        full_refresh            = true
        , materialized          = 'incremental'    
        , on_schema_change      = 'append_new_columns'
        , incremental_strategy  = 'append'
    )
}}

SELECT
    {# Previous incremental logging information is not relevant to keep for the snapshotting - i.e. load times, run id #}
    {{ dbt_utils.star(from=ref('transaction_with_line'), except=[var("dbt_run_id_col_name"), var("dbt_load_datetime_col_name")]) }}
    , {{ column_dbt_previous_month() }} AS {{ var("dbt_snapshot_col_name") }}     
    , {{ column_dbt_load_datetime() }}  AS {{ var("dbt_load_datetime_col_name") }} {# Load date is set to the current dbt time for all records inserted #}
    , '{{ var("dbt_run_id") }}'         AS {{ var("dbt_run_id_col_name") }}         
FROM {{ ref('transaction_with_line') }} t

{# To limite data volume, only snapshot the following scope #}
WHERE t.transaction_type IN ( '{{ var("transaction_snapshot_type") | join("', '") }}' )

{% if is_incremental() %}
    {# Checks if a snapshot has been made #}
    AND {{ column_dbt_previous_month() }} >= ( SELECT MAX ( incremental_date.{{ var("dbt_snapshot_col_name") }} ) FROM {{ this }} as incremental_date )
{% endif %}