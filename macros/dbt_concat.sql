{% macro sqlserver__concat(fields) -%}
    {%- if fields|length > 1 %}
        concat({{ fields|join(', ') }})
    {%- elif fields|length == 1 %}
        concat({{ fields[0] }}, '')
    {%- else %}
        ''
    {%- endif %}
{%- endmacro %}