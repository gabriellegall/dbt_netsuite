{% macro list_numerical_columns(model) %}
    {% set results = adapter.get_columns_in_relation(ref(model)) %}
    {% set numerical_columns = [] %}
    {% for column in results %}
        {% if column.data_type in ['int', 'integer', 'bigint', 'smallint', 'tinyint', 'decimal', 'numeric', 'float', 'double', 'real'] %}
            {% do numerical_columns.append(column.name) %}
        {% endif %}
    {% endfor %}
    {{ return(numerical_columns) }}
{% endmacro %}
