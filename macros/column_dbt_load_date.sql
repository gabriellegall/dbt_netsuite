{% macro column_dbt_load_date() %}
    CAST('{{ var("dbt_start_datetime") }}' AS DATE)
{% endmacro %}