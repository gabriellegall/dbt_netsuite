{% macro sqlserver__create_columns(relation, columns) %}

  {% for column in columns %}

    {% call statement() %}

      {# 10/03/2024 GLE : SQLServer requires 'add' instead of 'add column' #}
      alter table {{ relation }} add "{{ column.name }}" {{ column.data_type }};

    {% endcall %}

  {% endfor %}
  
{% endmacro %}