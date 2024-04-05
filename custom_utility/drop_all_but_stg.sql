{#
    Custom SQL script to be executed when all tables and views should be dropped from the database, except the stg layer. 
    This can be useful when a table is renamed, or when a materialization is changed
#}

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