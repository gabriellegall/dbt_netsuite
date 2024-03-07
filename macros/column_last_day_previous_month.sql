{% macro last_day_previous_month() %}
    EOMONTH('{{ var("dbt_start_date") }}', -1) AS last_day_of_previous_month;
{% endmacro %}