{{
    config (
        materialized = 'table'
    )
}}

SELECT TOP 1 
    CAST(ABS(CHECKSUM(NEWID())) % 100 AS INT) AS RandomNumber,
    CURRENT_TIMESTAMP AS CurrentDateTime
