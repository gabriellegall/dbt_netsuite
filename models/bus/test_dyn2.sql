{% set column_key = 'item_nsid' %}

SELECT 
    hist.*
FROM  
    {{ ref('historized_item') }} AS hist
    LEFT OUTER JOIN 
    ( SELECT * FROM {{ ref('historized_item') }} WHERE dbt_valid_to IS NULL ) live
        ON live.{{column_key}} = hist.{{column_key}}