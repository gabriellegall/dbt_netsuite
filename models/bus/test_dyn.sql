{% set excluded_columns = ['dbt_scd_id', 'dbt_updated_at', 'dbt_valid_from', 'dbt_valid_to'] %}
{% set selected_columns = [] %}
{% for col in adapter.get_columns_in_relation(ref('historized_item')) %}
    {% if col.name not in excluded_columns %}
        {% set _ = selected_columns.append(col.name ~ ' AS tokeep_' ~ col.name) %}
    {% endif %}
{% endfor %}

SELECT {{ selected_columns | join(', ') }}
FROM  {{ ref('historized_item') }}