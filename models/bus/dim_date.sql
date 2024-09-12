{{
    config (
        materialized = 'view'
    )
}}

{% set current_fiscal_year = 'CASE WHEN
  MONTH(' ~ column_dbt_load_date() ~ ') >= ' ~ var("date_table_fiscal_month") ~
  ' THEN YEAR(' ~ column_dbt_load_date() ~ ')
  ELSE YEAR(' ~ column_dbt_load_date() ~ ') - 1 
END'
%}

WITH cte_sequence AS (
  SELECT 
    DATEADD(DAY,value, CAST('{{ var("date_table_start_date") }}' AS DATE)) AS d
  FROM GENERATE_SERIES ( 
    0
    , DATEDIFF(DAY, CAST('{{ var("date_table_start_date") }}' AS DATE)
    , DATEADD(YEAR, {{ var("date_table_window_year") }}
    , {{ column_dbt_load_date() }}))
    , 1
    ) AS gs
),

cte_core_definition AS (
  SELECT
    date_standard                        = CONVERT(DATE,d)
    , date_int                           = FORMAT(CONVERT(DATE,d), 'yyyyMMdd')
    , day_of_month_number                = DATEPART(DAY,d)
    , day_of_week_number                 = DATEPART(WEEKDAY,d)
    , first_date_of_month                = DATEFROMPARTS(YEAR(d),MONTH(d),1)
    , last_date_of_month                 = DATEFROMPARTS(YEAR(d),MONTH(d),DAY(EOMONTH(d)))
    , is_current_day                     = IIF(CONVERT(DATE,d) =  {{ column_dbt_load_date() }}, 1, 0)
    , is_above_current_day               = IIF(CONVERT(DATE,d) >  {{ column_dbt_load_date() }}, 1, 0)
    , is_above_or_at_current_day         = IIF(CONVERT(DATE,d) >= {{ column_dbt_load_date() }}, 1, 0)
    , calendar_year_number               = DATEPART(YEAR,d)
    , calendar_first_day_of_year         = DATEFROMPARTS(YEAR(d),1,1)
    , calendar_last_day_of_year          = DATEFROMPARTS(YEAR(d),12,31)
    , calendar_month_of_year_number      = DATEPART(MONTH,d)
    , fiscal_year_number                 = CASE WHEN DATEPART(MONTH,d) >= {{ var("date_table_fiscal_month") }} THEN DATEPART(YEAR,d) ELSE DATEPART(YEAR,d) - 1 END
    , fiscal_first_day_of_year           = DATEFROMPARTS(CASE WHEN DATEPART(MONTH,d) >= {{ var("date_table_fiscal_month") }} THEN DATEPART(YEAR,d) ELSE DATEPART(YEAR,d) - 1 END, {{ var("date_table_fiscal_month") }}, 1)
    , fiscal_last_day_of_year            = DATEADD(DAY, -1, DATEFROMPARTS(CASE WHEN DATEPART(MONTH,d) >= {{ var("date_table_fiscal_month") }} THEN DATEPART(YEAR,d) + 1 ELSE DATEPART(YEAR,d) END, {{ var("date_table_fiscal_month") }}, 1))
    , fiscal_month_of_year_number        = (DATEPART(MONTH,d) + 12 - {{ var("date_table_fiscal_month") }}) % 12 + 1
  FROM cte_sequence
),

cte_date_dimension AS (
  SELECT
    date_standard AS pk_date_standard
    , date_int     
    , day_of_month_number   
    , day_of_week_number   
    , first_date_of_month  
    , last_date_of_month       
    , is_current_day      
    , is_above_current_day
    , is_above_or_at_current_day
    , calendar_year_number    
    , calendar_first_day_of_year        
    , calendar_last_day_of_year      
    , calendar_month_of_year_number   
    , fiscal_year_number
    , fiscal_first_day_of_year
    , fiscal_last_day_of_year
    , fiscal_month_of_year_number
    , is_prev_2y_fiscal_year          = IIF({{current_fiscal_year}} -2 = fiscal_year_number,1,0)
    , is_prev_1y_fiscal_year          = IIF({{current_fiscal_year}} -1 = fiscal_year_number,1,0)
    , is_current_fiscal_year          = IIF({{current_fiscal_year}}    = fiscal_year_number,1,0)
    , is_next_1y_fiscal_year          = IIF({{current_fiscal_year}} +1 = fiscal_year_number,1,0)
  FROM cte_core_definition
)

SELECT * FROM cte_date_dimension