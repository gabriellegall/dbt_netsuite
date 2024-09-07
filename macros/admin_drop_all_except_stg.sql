{# 
        This macro can be used to DROP all tables and views from the database, except those in the stg layer
        It can be useful when outdated table names or materializations should be deleted
#}

{% macro admin_drop_all(except_stg=False, specific_schema=None) -%}

    {% if except_stg %}
        {% set filter_condition = "AND s.name NOT LIKE '%stg%'" %}
    {% else %}
        {% set filter_condition = "" %}
    {% endif %}
    
    {% if specific_schema %}
        {% set schema_filter_condition = "AND s.name LIKE '" ~ specific_schema ~ "%'" %}
    {% else %}
        {% set schema_filter_condition = "" %}
    {% endif %}
    
    {% set sql %}
        DECLARE @sql NVARCHAR(MAX) = ''

        -- Drop all views except those in the STG schema (if except_stg=True) and specific_schema (if provided)
        SELECT @sql += 'DROP VIEW ' + QUOTENAME(s.name) + '.' + QUOTENAME(v.name) + ';'
        FROM sys.views v
        INNER JOIN sys.schemas s ON v.schema_id = s.schema_id
        WHERE 1=1 {{ filter_condition }} {{ schema_filter_condition }}

        -- Drop all tables except those in the STG schema (if except_stg=True) and specific_schema (if provided)
        SELECT @sql += 'DROP TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ';'
        FROM sys.tables t   
        INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
        WHERE 1=1 {{ filter_condition }} {{ schema_filter_condition }}

        -- Execute the generated SQL
        EXEC sp_executesql @sql
    {% endset %}

    {% do run_query(sql) %}

{%- endmacro %}
