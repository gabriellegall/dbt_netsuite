dbt_initiate:
	dbt seed
	dbt snapshot
	dbt run
	dbt test

dbt_reset: 
	dbt run-operation admin_drop_all_except_stg
	dbt snapshot 
	dbt run 
	dbt test