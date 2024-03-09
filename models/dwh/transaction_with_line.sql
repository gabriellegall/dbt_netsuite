{{
    config (
        materialized       = 'incremental'
        , unique_key       = ['transaction_nsid', 'transaction_line_nsid']
        , post_hook        = 'DELETE FROM {{this}} WHERE transaction_nsid IN ( SELECT transaction_nsid FROM [STG].[deleted_records] )'
        , on_schema_change = 'sync_all_columns'
    )
}}

SELECT 
    *
FROM {{ ref('prep_transaction_with_lines') }} t

{% if is_incremental() %}
    WHERE t.transaction_last_modified_date > ( SELECT MAX ( incremental_date.transaction_last_modified_date ) FROM {{ this }} as incremental_date );
{% endif %}