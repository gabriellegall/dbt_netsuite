{% macro column_dbt_load_datetime() %}
    CAST('{{ var("dbt_start_datetime") }}' AS DATETIME)
{% endmacro %}