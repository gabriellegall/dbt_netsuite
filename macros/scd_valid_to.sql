{% macro scd_valid_to() %}
    COALESCE(dbt_valid_to, cast('{{ var("future_proof_date") }}' AS datetime2)) AS scd_valid_to
{% endmacro %}