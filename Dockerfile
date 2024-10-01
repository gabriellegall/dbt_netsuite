FROM python:3.9-slim

ENV DBT_HOME=/netsuite_project
WORKDIR $DBT_HOME

RUN apt-get update && \
    apt-get install -y \
        git \
        apt-transport-https \
        curl \
        gnupg \
        unixodbc \
        unixodbc-dev \
        libodbc2 \
        make && \
    rm -rf /var/lib/apt/lists/*

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18

COPY . .

RUN git config --global --add safe.directory /netsuite_project

COPY requirements.txt .

RUN pip install --upgrade pip && \
    pip install -r requirements.txt

CMD ["/bin/bash"]
# CMD ["dbt", "seed", "--select", "customer", "--target", "prod"]
