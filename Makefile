BRANCH_NAME := $(shell python scripts/git_branch.py)

refresh_artifacts:
	del /q /s prod_run_artifacts\*
	xcopy /Y "target\*" "prod_run_artifacts\"

docker_start:
	docker volume create netsuite_data_volume_ssql
	docker volume ls
	docker build -t my-sqlserver-image .
	docker run -d -p 1433:1433 --name netsuite-sqlserver-container --mount source=netsuite_data_volume_ssql,target=/var/opt/mssql my-sqlserver-image

docker_end:
	docker stop netsuite-sqlserver-container
	docker rm netsuite-sqlserver-container

# admin command(s)
dbt_prod_hard_reset: 
	dbt run-operation admin_drop_all --target docker_prod --args "{'except_stg': False}"
	dbt seed --target docker_prod
	dbt snapshot --target docker_prod
	dbt run --target docker_prod
	dbt test --target docker_prod
	$(MAKE) refresh_artifacts

dbt_prod_soft_reset:
	dbt run-operation admin_drop_all --target docker_prod --args "{'except_stg': True}"
	dbt snapshot --target docker_prod
	dbt run --target docker_prod
	dbt test --target docker_prod
	$(MAKE) refresh_artifacts

launch_project:
	$(MAKE) docker_start
	python scripts/create_db.py
	$(MAKE) dbt_prod_hard_reset

# git command(s)
drop_branch_schema: 
	dbt run-operation admin_drop_all --vars "branch_name: $(BRANCH_NAME)" --args "{'except_stg': True, 'specific_schema': $(BRANCH_NAME)}"

# dev command(s)
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