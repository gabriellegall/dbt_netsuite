{{
    config (
        materialized = 'view'
    )
}}

WITH unioned_data AS (
    {{ dbt_utils.union_relations (
        relations = [
            ref('dataset_sales_pipeline'),
            ref('prep_budget_for_union')
        ],
        exclude=["_dbt_source_relation"]
    ) }}
)

{# Tableau does not support a mix of NULL and non-NULL values when aggregating - so we replace all blanks (created by the UNION) with 0 #}
{%- set sales_columns = adapter.get_columns_in_relation(ref('dataset_sales_pipeline')) | selectattr('name', 'ne', '_dbt_source_relation') | map(attribute='name') | list -%}
{%- set numerical_columns_sales = list_numerical_columns('dataset_sales_pipeline') -%}
{%- set budget_columns = adapter.get_columns_in_relation(ref('prep_budget_for_union')) | map(attribute='name') | list -%}

{%- set combined_columns = sales_columns + budget_columns -%}
{%- set unique_columns = combined_columns | unique -%}

SELECT
    {% for column in unique_columns %}
        {%- if column in numerical_columns_sales %}
            COALESCE({{ column }}, 0) as {{ column }}
        {%- else %}
            {{ column }}
        {%- endif -%}
        {%- if not loop.last -%}, {%- endif -%}
    {% endfor %}
FROM unioned_data