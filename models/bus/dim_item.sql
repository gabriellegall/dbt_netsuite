{{
    config(
        materialized = 'view'
    )
}}

SELECT 
    *
    , {{ scd_valid_to_fill_date() }}
FROM {{ ref('historized_item') }}