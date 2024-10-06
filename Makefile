BRANCH_NAME := $(shell python scripts/git_branch.py)

# Docker
docker_start:
	docker volume create netsuite_data_volume_ssql
	docker volume ls
	docker build -f deployment/deployment_sqlserver/docker/Dockerfile -t netsuite-sqlserver-image .
	docker run -d -p 1433:1433 --name netsuite-sqlserver-container --mount source=netsuite_data_volume_ssql,target=/var/opt/mssql netsuite-sqlserver-image

docker_end:
	docker stop netsuite-sqlserver-container
	docker rm netsuite-sqlserver-container

# admin command(s)
refresh_artifacts:
	powershell.exe -ExecutionPolicy Bypass -Command "if (-not (Test-Path "prod_run_artifacts")) {New-Item -Path "prod_run_artifacts" -ItemType Directory}"
	del /q /s prod_run_artifacts\*
	xcopy /Y "target\*" "prod_run_artifacts\"

dbt_prod_hard_reset: 
	python scripts/create_db.py
	dbt run-operation admin_drop_all --target prod --args "{'except_stg': False}"
	dbt seed --target prod
	dbt snapshot --target prod
	dbt run --target prod
	dbt test --target prod

dbt_prod_soft_reset:
	dbt run-operation admin_drop_all --target prod --args "{'except_stg': True}"
	dbt snapshot --target prod
	dbt run --target prod
	dbt test --target prod

dbt_prod_run:
	dbt snapshot --target prod
	dbt run --target prod
	dbt test --target prod

dbt_prod_compile:
	dbt compile --target prod

# dev command(s)
dbt_run:
ifndef MODEL
	$(error model is not defined. Please specify the model using MODEL=<your_model>)
endif
	dbt run --select $(MODEL) --vars "branch_name: $(BRANCH_NAME)" --defer --state prod_run_artifacts

dbt_test:
ifndef MODEL
	@echo "Running dbt test on everything..."
	dbt test --vars "branch_name: $(BRANCH_NAME)" --defer --state prod_run_artifacts
else
	@echo "Running dbt test on model: $(MODEL)..."
	dbt test --select $(MODEL) --vars "branch_name: $(BRANCH_NAME)" --defer --state prod_run_artifacts
endif

# dev-to-prod command(s)
drop_branch_schema: 
	dbt run-operation admin_drop_all --vars "branch_name: $(BRANCH_NAME)" --args "{'except_stg': True, 'specific_schema': $(BRANCH_NAME)}"
