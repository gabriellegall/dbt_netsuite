{% macro column_dbt_previous_month() %}
    EOMONTH('{{ var("dbt_start_date") }}', -1)
{% endmacro %}