
{{
    config(
        materialized = 'incremental'
        , unique_key = ['transaction_nsid', 'transaction_line_nsid']
        , post_hook  = 'DELETE FROM {{this}} WHERE transaction_nsid IN (SELECT transaction_nsid FROM [STG].[deleted_records] )'
    )
}}

SELECT 
    t.transaction_nsid
    , tl.transaction_line_nsid
    , t.transaction_type
    , t.transaction_number
    , t.transaction_date
    , t.transaction_last_modified_date
    , tl.item_nsid
    , {{ dbt_utils.generate_surrogate_key ( ['tl.item_nsid'] )}} AS fk_{{ var("item_key") }}
    , t.bu_nsid
    , {{ dbt_utils.generate_surrogate_key ( ['t.bu_nsid'] )}} AS fk_{{ var("bu_key") }}

FROM {{ ref('transaction') }} t
    LEFT OUTER JOIN {{ ref('transactionline') }} tl
    ON t.transaction_nsid = tl.transaction_nsid

{% if is_incremental() %}
    WHERE t.transaction_last_modified_date >= ( SELECT MAX ( incremental_date.transaction_last_modified_date ) FROM {{ this }} as incremental_date);
{% endif %}