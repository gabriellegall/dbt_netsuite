{# 
        This macro can be used to DROP all tables and views from the database, except those in the stg layer
        It can be useful when outdated table names or materializations should be deleted
#}

{% macro admin_drop_all_except_stg() -%}

{% set sql %}
        DECLARE @sql NVARCHAR(MAX) = ''

        -- Drop all views except those in the STG schema
        SELECT @sql += 'DROP VIEW ' + QUOTENAME(s.name) + '.' + QUOTENAME(v.name) + ';'
        FROM sys.views v
        INNER JOIN sys.schemas s ON v.schema_id = s.schema_id
        WHERE s.name != 'stg'

        -- Drop all tables except those in the STG schema
        SELECT @sql += 'DROP TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ';'
        FROM sys.tables t   
        INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
        WHERE s.name != 'stg'

        -- Execute the generated SQL
        EXEC sp_executesql @sql
{% endset %}

{% do run_query(sql) %}

{%- endmacro %}
