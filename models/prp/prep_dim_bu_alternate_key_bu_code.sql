{# There is no bu_nsid inside the budget file. The client wants to use the bu_code as join key one the most recent record #}
{# Therefore, this table is designed to offer an alternate entry key to the dimension table #}

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