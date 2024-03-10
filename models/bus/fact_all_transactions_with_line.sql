{{
    config(
        materialized = 'view'
    )
}}

SELECT 
    * 
FROM {{ ref("prep_all_transactions_with_line") }} t
LEFT OUTER JOIN {{ ref("dim_item") }} it
    ON it.pk_{{ var("item_key") }} = t.fk_{{ var("item_key") }}
    AND t.transaction_date BETWEEN it.scd_valid_from_fill_date AND it.scd_valid_to_fill_date