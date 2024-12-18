{{
    config (
        materialized            = 'incremental'
        , unique_key            = ['transaction_nsid']
        , incremental_strategy  = 'delete+insert'
        , pre_hook              = ['-- depends_on: {{ ref("deleted_records") }}
                                    {% if is_incremental() %}
                                    DELETE FROM {{this}} WHERE transaction_nsid IN 
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
                                    )
                                    {% endif %}']      
        , on_schema_change      = 'sync_all_columns'
        , as_columnstore        = false
    )
}}

SELECT * FROM {{ ref("prep_transaction_with_lines") }}

{# Load transactions that have been modified the same day or after the latest modifications loaded in the DWH table #}
-- depends_on: {{ ref('prep_delta_records') }}
{% if is_incremental() %}
    WHERE transaction_nsid IN
    ( 
        SELECT 
            transaction_nsid 
        FROM {{ ref("prep_delta_records") }}  
        WHERE 
            CAST ( transaction_global_last_modified_date AS DATE ) >=
                {# Latest modifications loaded in the DWH table #}
                GREATEST (
                      ( SELECT MAX ( CAST ( incremental_date.transaction_last_modified_date AS DATE ) ) FROM {{ this }} as incremental_date )
                    , ( SELECT MAX ( CAST ( incremental_date.transaction_line_last_modified_date AS DATE ) ) FROM {{ this }} as incremental_date )
                )
    )           
{% endif %}