{{
    config (
        materialized = 'view'
    )
}}

WITH cte_row_id AS (
SELECT 
  *
  , ROW_NUMBER() OVER (PARTITION BY user_email ORDER BY user_email) as row_id
FROM {{ ref("historized_user_rls") }}
WHERE dbt_valid_to IS NULL
) 

, cte_authorized_bu_code AS (
SELECT
  user_email,
  row_id,
  LTRIM(RTRIM(value)) AS authorized_bu_code
FROM cte_row_id
CROSS APPLY STRING_SPLIT(authorized_bu_code, ',') AS authorized_bu_code
)

, cte_authorized_customer_name AS (
SELECT
  user_email,
  row_id,
  LTRIM(RTRIM(value)) AS authorized_customer_name
FROM cte_row_id
CROSS APPLY STRING_SPLIT(authorized_customer_name, ',') AS authorized_customer_name
)

, cte_authorized_item_type AS (
SELECT
  user_email,
  row_id,
  LTRIM(RTRIM(value)) AS authorized_item_type
FROM cte_row_id
CROSS APPLY STRING_SPLIT(authorized_item_type, ',') AS authorized_item_type
)

SELECT 
	bu.user_email
  , bu.row_id
	, bu.authorized_bu_code
	, cust.authorized_customer_name
  , it.authorized_item_type
FROM cte_authorized_bu_code bu
INNER JOIN cte_authorized_customer_name cust 
    ON bu.user_email = cust.user_email
    AND bu.row_id = cust.row_id
INNER JOIN cte_authorized_item_type it 
    ON bu.user_email = it.user_email
    AND bu.row_id = it.row_id