{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {# 10/03/2024 GLE : Removed the user-specific schemas #}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}