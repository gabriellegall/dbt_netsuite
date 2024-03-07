{% macro column_scd_valid_to_fill_date() %}
    COALESCE(hist.dbt_valid_to, cast('{{ var("future_proof_date") }}' AS datetime2)) AS scd_valid_to_fill_date
{% endmacro %}