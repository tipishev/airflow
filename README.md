# Locally Running Airflow

Makefile and configuration to run Apache Airflow with Postgres DB backend and `LocalExecutor`.

## Prerequisites

* Python3.6
* virtualenv
* Postgres

## Initial Setup

```bash
make requirements
make initdb
```

## Usage

```bash
# in two terminals

make webserver
make scheduler
```

Open http://localhost:8080


To pass the metadata database connection string

```bash
export AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:password@localhost
```
