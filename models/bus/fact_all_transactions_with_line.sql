{{
    config(
        materialized = 'view'
    )
}}

{% set excluded_columns = ['dbt_scd_id', 'dbt_updated_at', 'dbt_valid_from', 'dbt_valid_to', 'scd_valid_from_fill_date', 'scd_valid_to_fill_date', 'version_number'] %}

SELECT 
    t.* 
    , {{ dbt_utils.star(from=ref('dim_item'), except = excluded_columns ) }}
    , {{ dbt_utils.star(from=ref('dim_bu'), except = excluded_columns ) }}

FROM {{ ref("prep_all_transactions_with_line") }} t
LEFT OUTER JOIN {{ ref("dim_item") }} it
    ON it.pk_{{ var("item_key") }} = t.fk_{{ var("item_key") }}
    AND t.transaction_date BETWEEN it.scd_valid_from_fill_date AND it.scd_valid_to_fill_date
LEFT OUTER JOIN {{ ref("dim_bu") }} bu
    ON bu.pk_{{ var("business_unit_key") }} = t.fk_{{ var("business_unit_key") }}
    AND t.transaction_date BETWEEN bu.scd_valid_from_fill_date AND bu.scd_valid_to_fill_date