{{
    config (
        materialized = 'view'
    )
}}

WITH cte_scope AS (
SELECT 
    {{ dbt_utils.star(from=ref('fact_all_transactions_with_line')) }}
    , CAST ( CASE WHEN t.transaction_type IN ('Opportunity', 'Sales Order') THEN t.expected_delivery_date ELSE t.transaction_date END AS DATE ) AS calculation_date
FROM {{ ref("fact_all_transactions_with_line") }} t 
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
)

{% set currencies = ['bu_amount', 'usd_amount', 'dynamic_amount'] %}
, cte_calculate AS (
SELECT 
    t.*
    {% for currency in currencies %}
        , IIF(d_calc.is_prev_2y_fiscal_year = 1, {{ currency }}, 0) AS total_{{ currency }}_prev_2y_fiscal_year
        , IIF(d_calc.is_prev_1y_fiscal_year = 1, {{ currency }}, 0) AS total_{{ currency }}_prev_1y_fiscal_year
        , IIF(d_calc.is_current_fiscal_year = 1, {{ currency }}, 0) AS total_{{ currency }}_current_fiscal_year
        , IIF(d_calc.is_next_1y_fiscal_year = 1, {{ currency }}, 0) AS total_{{ currency }}_next_1y_fiscal_year
    {% endfor %}
    {% for currency in currencies %}
        {% for type in var("sales_scope_type") %}
        , IIF(d_calc.is_prev_2y_fiscal_year = 1 AND t.transaction_type = '{{ type }}', {{ currency }}, 0) AS {{ type | lower | replace(" ", "_") }}_{{ currency }}_prev_2y_fiscal_year
        , IIF(d_calc.is_prev_1y_fiscal_year = 1 AND t.transaction_type = '{{ type }}', {{ currency }}, 0) AS {{ type | lower | replace(" ", "_") }}_{{ currency }}_prev_1y_fiscal_year
        , IIF(d_calc.is_current_fiscal_year = 1 AND t.transaction_type = '{{ type }}', {{ currency }}, 0) AS {{ type | lower | replace(" ", "_") }}_{{ currency }}_current_fiscal_year
        , IIF(d_calc.is_next_1y_fiscal_year = 1 AND t.transaction_type = '{{ type }}', {{ currency }}, 0) AS {{ type | lower | replace(" ", "_") }}_{{ currency }}_next_1y_fiscal_year
        {% endfor %}
    {% endfor %}
FROM cte_scope t 
LEFT OUTER JOIN {{ ref("dim_date") }} d_calc
    ON d_calc.pk_date_standard = t.calculation_date 
)

SELECT 
    t.*
    , {{ dbt_utils.star(from=ref('dim_item')    , except = var("scd_excluded_col_name") ) }}
    , {{ dbt_utils.star(from=ref('dim_customer'), except = var("scd_excluded_col_name") ) }}
FROM cte_calculate t
LEFT OUTER JOIN {{ ref("dim_customer") }} cu
    ON cu.pk_{{ var("customer_key") }} = t.fk_{{ var("customer_key") }}
    AND t.transaction_date BETWEEN cu.scd_valid_from_fill_date AND cu.scd_valid_to_fill_date
LEFT OUTER JOIN {{ ref("dim_item") }} it
    ON it.pk_{{ var("item_key") }} = t.fk_{{ var("item_key") }}
    AND t.transaction_date BETWEEN it.scd_valid_from_fill_date AND it.scd_valid_to_fill_date