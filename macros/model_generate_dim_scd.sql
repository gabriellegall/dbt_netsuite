{% macro model_generate_dim_scd(column_key, table_name) %}

    {% set excluded_columns = [column_key, 'dbt_scd_id', 'dbt_updated_at', 'dbt_valid_from', 'dbt_valid_to'] %}

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
        , {{ dbt_utils.generate_surrogate_key(['hist.' ~ column_key])}} AS pk_{{ column_key }}
        , {{ excluded_columns_meta | join(', ') }}
        , IIF ( ROW_NUMBER() OVER ( PARTITION BY hist.{{ column_key }} ORDER BY hist.dbt_valid_from ) = 1
            , CAST('{{ var("past_proof_date") }}' AS DATETIME2)
            , hist.dbt_valid_from )                                                             AS scd_valid_from_fill_date
        , COALESCE(hist.dbt_valid_to, cast('{{ var("future_proof_date") }}' AS DATETIME2))      AS scd_valid_to_fill_date
        , ROW_NUMBER() OVER ( PARTITION BY hist.{{ column_key }} ORDER BY hist.dbt_valid_from ) AS version_number
    FROM  
        {{ table_name }} AS hist
        LEFT OUTER JOIN 
        ( SELECT * FROM {{ table_name }} WHERE dbt_valid_to IS NULL ) live
            ON live.{{ column_key }} = hist.{{ column_key }}

{% endmacro %}