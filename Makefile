BRANCH_NAME := $(shell python scripts/git_branch.py)

refresh_artifacts:
	del /q /s prod_run_artifacts\*
	xcopy /Y "target\*" "prod_run_artifacts\"

dbt_prod_hard_reset: 
	dbt run-operation admin_drop_all --target prod --args "{'except_stg': False}"
	dbt seed --target prod
	dbt snapshot --target prod
	dbt run --target prod
	dbt test --target prod
	$(MAKE) refresh_artifacts

dbt_prod_soft_reset:
	dbt run-operation admin_drop_all --target prod --args "{'except_stg': True}"
	dbt snapshot --target prod
	dbt run --target prod
	dbt test --target prod
	$(MAKE) refresh_artifacts

drop_branch_schema: 
	dbt run-operation admin_drop_all --vars "branch_name: $(BRANCH_NAME)" --args "{'except_stg': True, 'specific_schema': $(BRANCH_NAME)}"

dbt_run:
ifndef MODEL
	$(error model is not defined. Please specify the model using MODEL=<your_model>)
endif
	dbt run --select $(MODEL) --vars "branch_name: $(BRANCH_NAME)" --defer --state prod_run_artifacts

dbt_test:
ifndef MODEL
	$(error model is not defined. Please specify the model using MODEL=<your_model>)
endif
	dbt test --select $(MODEL) --vars "branch_name: $(BRANCH_NAME)" --defer --state prod_run_artifacts