SELECT 
    {{ dbt_utils.star(from=ref('fact_all_transactions_with_line')) }}
    , CASE WHEN t.transaction_type IN ('Opportunity', 'Sales Order') THEN t.expected_delivery_date ELSE t.transaction_date END AS calculation_date
    , {{ dbt_utils.star(from=ref('dim_item')    , except = var("scd_excluded_col_name") ) }}
    , {{ dbt_utils.star(from=ref('dim_customer'), except = var("scd_excluded_col_name") ) }}

FROM {{ ref("fact_all_transactions_with_line") }} t
LEFT OUTER JOIN {{ ref("dim_customer") }} cu
    ON cu.pk_{{ var("customer_key") }} = t.fk_{{ var("customer_key") }}
    AND t.transaction_date BETWEEN cu.scd_valid_from_fill_date AND cu.scd_valid_to_fill_date
LEFT OUTER JOIN {{ ref("dim_item") }} it
    ON it.pk_{{ var("item_key") }} = t.fk_{{ var("item_key") }}
    AND t.transaction_date BETWEEN it.scd_valid_from_fill_date AND it.scd_valid_to_fill_date

{# Scope of the dataset #}
WHERE t.transaction_type IN ( '{{ var("sales_scope_type") | join("', '") }}' )
AND
    ( 
        ( t.transaction_type NOT IN ('Opportunity', 'Sales Order') )
        OR 
        ( t.transaction_type = 'Opportunity' AND t.transaction_status IN ( '{{ var("opportunity_open_scope") | join("', '") }}' ) )
        OR
        ( t.transaction_type = 'Sales Order' AND t.transaction_status IN ( '{{ var("sales_order_open_scope") | join("', '") }}' ) )
    )