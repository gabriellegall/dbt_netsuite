{{
    config (
        materialized            = 'incremental'
        , unique_key            = ['transaction_nsid']
        , incremental_strategy  = 'delete+insert'
        , pre_hook              = 'DELETE FROM {{this}} WHERE transaction_nsid IN 
                                    (
                                    SELECT
                                        transaction_nsid
                                    FROM {{ ref("deleted_records") }}
                                    WHERE 
                                        CAST ( deleted_date AS DATE ) >= 
                                            GREATEST (
                                                CAST ( ( SELECT MAX ( incremental_date.transaction_last_modified_date ) FROM {{ this }} as incremental_date ) AS DATE )
                                                , CAST ( ( SELECT MAX ( incremental_date.transaction_line_last_modified_date ) FROM {{ this }} as incremental_date ) AS DATE )
                                            )
                                    )'
        , on_schema_change      = 'sync_all_columns'
    )
}}

SELECT 
    COALESCE(t.transaction_nsid, -1)                                AS transaction_nsid
    , COALESCE(tl.transaction_line_nsid,-1)                         AS transaction_line_nsid
    , t.transaction_last_modified_date
    , tl.transaction_line_last_modified_date
    , t.transaction_type
    , t.transaction_number
    , t.transaction_status
    , CAST(t.transaction_date AS DATETIME2)                         AS transaction_date
    , t.expected_delivery_date
    , tl.foreign_amount
    , tl.foreign_currency
    , tl.quantity
    , tl.bu_rate
    , tl.foreign_amount * tl.bu_rate                                AS bu_amount 
    , {{ dbt_utils.generate_surrogate_key ( ['tl.item_nsid'] )}}    AS fk_{{ var("item_key") }}
    , {{ dbt_utils.generate_surrogate_key ( ['t.bu_nsid'] )}}       AS fk_{{ var("business_unit_key") }}
    , {{ dbt_utils.generate_surrogate_key ( ['t.customer_nsid'] )}} AS fk_{{ var("customer_key") }}
    , {{ column_dbt_load_datetime() }}                              AS {{ var("dbt_load_datetime_col_name") }}
    , '{{ var("dbt_run_id") }}'                                     AS {{ var("dbt_run_id_col_name") }}

FROM {{ ref('transaction') }} t
    LEFT OUTER JOIN {{ ref('transactionline') }} tl
    ON t.transaction_nsid = tl.transaction_nsid

-- depends_on: {{ ref('prep_delta_records') }}
{# Load transactions that have been modified the same day or after the latest modifications loaded in the DWH table #}
{% if is_incremental() %}
    WHERE t.transaction_nsid IN
    ( 
        SELECT 
            transaction_nsid 
        FROM {{ ref("prep_delta_records") }}  
        WHERE 
            CAST ( transaction_global_last_modified_date AS DATE ) >= 
                {# Latest modifications loaded in the DWH table #}
                GREATEST (
                      CAST ( ( SELECT MAX ( incremental_date.transaction_last_modified_date ) FROM {{ this }} as incremental_date ) AS DATE )
                    , CAST ( ( SELECT MAX ( incremental_date.transaction_line_last_modified_date ) FROM {{ this }} as incremental_date ) AS DATE )
                )
    )           
{% endif %}