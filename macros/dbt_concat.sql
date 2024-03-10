{# 10/03/2024 GLE : SQLServer requires to manage concat of a single field #}

{% macro sqlserver__concat(fields) -%}
    {%- if fields|length > 1 %}
        concat({{ fields|join(', ') }})
    {%- elif fields|length == 1 %}
        concat({{ fields[0] }}, '')
    {%- else %}
        ''
    {%- endif %}
{%- endmacro %}