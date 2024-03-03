
{{
    config(
        materialized = 'view'
    )
}}

SELECT 
    *
FROM {{ source('dim_item') }}