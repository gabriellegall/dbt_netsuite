{% macro model_generate_dataset_rls(data_model, scenario, primary_key) %}

{% set scenario_conditions = {
    "customer_bu_item": """
        (ds.live_customer_name = rls.authorized_customer_name OR rls.authorized_customer_name = 'All')
        AND (ds.live_bu_code = rls.authorized_bu_code OR rls.authorized_bu_code = 'All')
        AND (ds.live_item_type = rls.authorized_item_type OR rls.authorized_item_type = 'All')
    """,
    "customer_bu": """
        (ds.live_customer_name = rls.authorized_customer_name OR rls.authorized_customer_name = 'All')
        AND (ds.live_bu_code = rls.authorized_bu_code OR rls.authorized_bu_code = 'All')
        AND (rls.authorized_item_type = 'All')
    """,
    "bu": """
        (rls.authorized_customer_name = 'All')
        AND (ds.live_bu_code = rls.authorized_bu_code OR rls.authorized_bu_code = 'All')
        AND (rls.authorized_item_type = 'All')        
    """,
    "customer": """
        (ds.live_customer_name = rls.authorized_customer_name OR rls.authorized_customer_name = 'All')
        AND (rls.authorized_bu_code = 'All')
        AND (rls.authorized_item_type = 'All')    
    """
} %}

{% set condition = scenario_conditions[scenario] %}

{% set sql_statement %}
    SELECT MAX(row_id) AS max_row_id FROM {{ ref ("prep_rls_normalize") }}
{% endset %}
{%- set max_row_id = dbt_utils.get_single_value(sql_statement) -%}

WITH cte_union_all_conditions AS (
{% if execute %}
    {% for i in range(1, max_row_id + 1) %}
        SELECT
            ds.*,
            rls.user_email
        FROM {{ data_model }} ds
        LEFT JOIN {{ ref("prep_rls_normalize") }} rls
            ON  {{ condition|format(i=i) }}
        WHERE rls.row_id = {{ i }}
        {% if not loop.last %} UNION ALL {% endif %}
    {% endfor %}
{% endif %}
),

cte_duplicate_identification AS (
SELECT 
    *
    , ROW_NUMBER() OVER (PARTITION BY user_email, {{ primary_key }} ORDER BY {{ primary_key }}) AS id_duplicate
FROM cte_union_all_conditions
)

SELECT 
    *
FROM cte_duplicate_identification
WHERE id_duplicate = 1

{% endmacro %}