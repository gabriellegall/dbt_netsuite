{{
    config (
        materialized = 'view'
    )
}}

WITH dim_business_unit_bu_code_id AS 
(
    SELECT 
        *
        , ROW_NUMBER() OVER(PARTITION BY live_bu_code ORDER BY dbt_updated_at DESC) AS bu_code_id_key
    FROM {{ ref("dim_bu") }}
)

SELECT * FROM dim_business_unit_bu_code_id WHERE bu_code_id_key = 1