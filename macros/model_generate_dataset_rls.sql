{% macro model_generate_dataset_rls(data_model, scenario) %}

{% set scenario_conditions = {
    "all_conditions": """
        (ds.live_customer_name = rls.authorized_customer_name OR rls.authorized_customer_name = 'All')
        AND (ds.live_bu_code = rls.authorized_bu_code OR rls.authorized_bu_code = 'All')
        AND (ds.live_item_type = rls.authorized_item_type OR rls.authorized_item_type = 'All')
    """,
    "no_item_condition": """
        (ds.live_customer_name = rls.authorized_customer_name OR rls.authorized_customer_name = 'All')
        AND (ds.live_bu_code = rls.authorized_bu_code OR rls.authorized_bu_code = 'All')
    """,
    "bu_condition": """
        (ds.live_bu_code = rls.authorized_bu_code OR rls.authorized_bu_code = 'All')
    """,
    "customer_condition": """
        (ds.live_customer_name = rls.authorized_customer_name OR rls.authorized_customer_name = 'All')
    """
} %}

{% set condition = scenario_conditions[scenario] %}

{% set nb_cte_query = "SELECT MAX(row_id) AS max_row_id FROM netsuite.prp.prep_rls_normalize" %}
{% set nb_cte = run_query(nb_cte_query) %}

{% if execute %}
{# https://docs.getdbt.com/reference/dbt-jinja-functions/execute #}

    {% for i in range(1, nb_cte[0].max_row_id + 1) %}
        SELECT
            ds.*,
            rls.user_email
        FROM {{ data_model }} ds
        LEFT JOIN {{ ref("prep_rls_normalize") }} rls
            ON  {{ condition|format(i=i) }}
        WHERE rls.row_id = {{ i }}
        {% if not loop.last %} UNION {% endif %}
    {% endfor %}

{% endif %}

{% endmacro %}