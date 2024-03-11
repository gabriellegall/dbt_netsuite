{{
    config (
        materialized       = 'incremental'
        , unique_key       = ['transaction_nsid', 'transaction_line_nsid']
        , post_hook        = 'DELETE FROM {{this}} WHERE transaction_nsid IN ( SELECT transaction_nsid FROM [STG].[deleted_records] )'
        , on_schema_change = 'sync_all_columns'
    )
}}

SELECT 
    COALESCE(t.transaction_nsid, -1)                                AS transaction_nsid
    , COALESCE(tl.transaction_line_nsid,-1)                         AS transaction_line_nsid
    , t.transaction_last_modified_date
    , t.transaction_type
    , t.transaction_number
    , CAST(t.transaction_date AS DATETIME2)                         AS transaction_date
    , t.expected_delivery_date
    , {{ dbt_utils.generate_surrogate_key ( ['tl.item_nsid'] )}}    AS fk_{{ var("item_key") }}
    , {{ dbt_utils.generate_surrogate_key ( ['t.bu_nsid'] )}}       AS fk_{{ var("business_unit_key") }}
    , t.customer_nsid
    , {{ column_dbt_load_datetime() }}                              AS {{ var("dbt_load_datetime_col_name") }}
    , '{{ var("dbt_run_id") }}'                                     AS {{ var("dbt_run_id_col_name") }}

FROM {{ ref('transaction') }} t
    LEFT OUTER JOIN {{ ref('transactionline') }} tl
    ON t.transaction_nsid = tl.transaction_nsid

{% if is_incremental() %}
    WHERE t.transaction_last_modified_date > ( SELECT MAX ( incremental_date.transaction_last_modified_date ) FROM {{ this }} as incremental_date );
{% endif %}