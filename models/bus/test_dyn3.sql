{% set excluded_columns = ['dbt_scd_id', 'dbt_updated_at', 'dbt_valid_from', 'dbt_valid_to'] %}
{% set table_name = ref('historized_item') %}
{% set column_key = 'item_nsid' %}

{% set selected_columns_1 = [] %}
{% set selected_columns_2 = [] %}
{% set excluded_columns_meta = [] %}

{% for col_name in excluded_columns %}
    {% set _ = excluded_columns_meta.append('hist.' ~ col_name) %}
{% endfor %}

{% for col in adapter.get_columns_in_relation(table_name) %}
    {% if col.name not in excluded_columns %}
        {% set _ = selected_columns_1.append('hist.' ~ col.name ~ ' AS hist_' ~ col.name) %}
        {% set _ = selected_columns_2.append('live.' ~ col.name ~ ' AS live_' ~ col.name) %}        
    {% endif %}
{% endfor %}

SELECT 
    {{ selected_columns_1 | join(', ') }}
    , {{ selected_columns_2 | join(', ') }}
    , {{ excluded_columns_meta | join(', ') }}
FROM  
    {{ table_name }} AS hist
    LEFT OUTER JOIN 
    ( SELECT * FROM {{ table_name }} WHERE dbt_valid_to IS NULL ) live
        ON live.{{column_key}} = hist.{{column_key}}