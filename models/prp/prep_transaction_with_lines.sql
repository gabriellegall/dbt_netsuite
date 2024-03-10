
{{
    config (
        materialized = 'ephemeral'
    )
}}

SELECT 
    COALESCE(t.transaction_nsid, -1)                                AS transaction_nsid
    , COALESCE(tl.transaction_line_nsid,-1)                         AS transaction_line_nsid
    , t.transaction_last_modified_date
    , t.transaction_type
    , t.transaction_number
    , t.transaction_date
    , t.expected_delivery_date
    , tl.item_nsid
    , {{ dbt_utils.generate_surrogate_key ( ['tl.item_nsid'] )}}    AS fk_{{ var("item_key") }}
    , t.bu_nsid
    , {{ dbt_utils.generate_surrogate_key ( ['t.bu_nsid'] )}}       AS fk_{{ var("business_unit_key") }}
    , t.customer_nsid
    , {{ column_dbt_load_datetime() }}                              AS {{ var("dbt_load_datetime_col_name") }}
    , '{{ var("dbt_run_id") }}'                                     AS {{ var("dbt_run_id_col_name") }}

FROM {{ ref('transaction') }} t
    LEFT OUTER JOIN {{ ref('transactionline') }} tl
    ON t.transaction_nsid = tl.transaction_nsid