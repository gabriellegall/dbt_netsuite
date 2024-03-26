{{
    config (
        materialized = 'view'
    )
}}



WITH cte_sequence AS (
  SELECT DATEADD(DAY,value, CAST('{{ var("date_table_start_date") }}' AS DATE)) AS d
  FROM GENERATE_SERIES(0, DATEDIFF(DAY, CAST('{{ var("date_table_start_date") }}' AS DATE), DATEADD(YEAR, {{ var("date_table_window_year") }}, {{ column_dbt_load_date() }})), 1) AS gs
),

cte_core_definition AS (
  SELECT
    date_standard                           = CONVERT(DATE,d),
    formatted_date                          = FORMAT(CONVERT(DATE,d), 'yyyyMMdd'), -- Formatted date as YYYYMMDD
    day_of_month_number                     = DATEPART(DAY,d),
    day_of_week_number                      = DATEPART(WEEKDAY,d),
    first_date_of_month                     = DATEFROMPARTS(YEAR(d),MONTH(d),1),
    last_date_of_month                      = DATEFROMPARTS(YEAR(d),MONTH(d),DAY(EOMONTH(d))),
    month_of_year_number                    = DATEPART(MONTH,d),
    year_number                             = DATEPART(YEAR,d),
    first_day_of_year                       = DATEFROMPARTS(YEAR(d),1,1),
    last_day_of_year                        = DATEFROMPARTS(YEAR(d),12,31),
    is_current_day                          = IIF(CONVERT(DATE,d) = {{ column_dbt_load_date() }}, 1, 0),
    is_current_day_last_year                = IIF(CONVERT(DATE,d) = DATEADD(YEAR, -1, {{ column_dbt_load_date() }}),1,0),
    is_above_current_day                    = IIF(CONVERT(DATE,d) > {{ column_dbt_load_date() }}, 1, 0),
    is_above_current_day_last_year          = IIF(CONVERT(DATE,d) > DATEADD(YEAR, -1, {{ column_dbt_load_date() }}),1,0),
    is_above_or_at_current_day              = IIF(CONVERT(DATE,d) >= {{ column_dbt_load_date() }}, 1, 0),
    is_above_or_at_current_day_last_year    = IIF(CONVERT(DATE,d) >= DATEADD(YEAR, -1, {{ column_dbt_load_date() }}),1,0)
  FROM cte_sequence
),

cte_date_dimension AS (
  SELECT
    date_standard,
    formatted_date,
    month_of_year_number,
    year_number,
    first_day_of_year,
    last_day_of_year,
    first_date_of_month,
    last_date_of_month,
    is_current_day,
    is_above_current_day,
    is_above_or_at_current_day,
    is_ytd_prev_1y               = IIF (is_above_current_day_last_year = 0 AND year_number = DATEPART(YEAR, {{ column_dbt_load_date() }})-1,1,0),
    is_ytd_current_year          = IIF (is_above_current_day = 0 AND year_number = DATEPART(YEAR, {{ column_dbt_load_date() }}),1,0),
    is_prev_2y                   = IIF (year_number = DATEPART(YEAR, {{ column_dbt_load_date() }})-2,1,0),
    is_prev_1y                   = IIF (year_number = DATEPART(YEAR, {{ column_dbt_load_date() }})-1,1,0),
    is_current_year              = IIF (year_number = DATEPART(YEAR, {{ column_dbt_load_date() }}),1,0),
    is_next_year                 = IIF (year_number = DATEPART(YEAR, {{ column_dbt_load_date() }})+1,1,0)
  FROM cte_core_definition
)

SELECT * FROM cte_date_dimension