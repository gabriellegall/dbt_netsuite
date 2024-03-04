{{
    config(
        materialized = 'view'
    )
}}

SELECT 
    *
    , {{ scd_valid_to() }}
FROM {{ ref('historized_item') }}