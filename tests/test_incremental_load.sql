{{ config ( 
	severity = 'error' 
	)
}}



WITH cte_incremental_table AS (
SELECT
	*
	, CHECKSUM (*) AS checksum_result
FROM {{ ref("transaction_with_line") }} )

, cte_current_table AS (
SELECT
	*
	, CHECKSUM (*) AS checksum_result
FROM {{ ref("prep_transaction_with_lines") }} )

SELECT 
	cte_incremental_table.transaction_nsid			AS incremental_transaction_nsid
    , cte_incremental_table.transaction_line_nsid	AS incremental_transaction_line_nsid
	, cte_current_table.transaction_nsid			AS current_transaction_nsid
    , cte_current_table.transaction_line_nsid		AS current_transaction_line_nsid
	, CASE 
		WHEN cte_incremental_table.transaction_nsid IS NOT NULL THEN 'Hash present in incremental table exclusively'
		WHEN cte_current_table.transaction_nsid IS NOT NULL THEN 'Hash present in current table exclusively'
	END 											AS control_warning_description
	
FROM cte_incremental_table
FULL OUTER JOIN cte_current_table
	ON cte_incremental_table.checksum_result = cte_current_table.checksum_result
WHERE cte_incremental_table.checksum_result IS NULL
	OR cte_current_table.checksum_result IS NULL