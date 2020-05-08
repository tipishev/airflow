# My notes on playing around with Airflow

`pip instal apache-airflow` installs a lot of stuff: Flask, pandas, sqlalchemy, gunicorn, and their grandma. Takes a couple of minutes to install. Pandas got downgraded from 1+ to 0.25.3, there an [issue for that](https://github.com/apache/airflow/issues/7905)

The installed version of is `apache-airflow==1.10.10`

`airflow initdb` used alembic to initialize a SQLlite.

Upon running the instance and scheduler the scheduler noted that SQLlite should not have more than 2 threads running, nice.

There's a plethora of extra packages to install, mostly integrations with more services (aws, gcp, azure, slack, etc.) and databases.

## Looking at the `~/airflow/airflow.cfg`

### Core

* dags_folder
* logs_folder

..folder? why not dir/directory?

The configuration file is 1k lines with comments. OMG.

remote logging on Elastic, nice

`hostname_callable` to resolve the host

Different Executor classes are available.

Db connections can be pooled

A separate schema can be used for the metadatabase

`load_examples = False` to disable default 21 example DAGs that come with airflow.o

Airflow comes with plugins, `plugins_folder`

Hm.. these guys talk about v2.0, especially around security features. Looks like a migration in the future.

has conventions on DAG file names (`dag_discovery_safe_mode`)

can optionally store complete and serialized DAGs in the DB rather than in the files, for performance I guess.

a DAG can have SLAs associated with it. I guess it's nice for predictability.

### Secrets

Secrets backends, amazon stuff is available

### Cli

Local/DB client

endpoint_url


### Debug
`fail_fast` setting

### webserver

Airflow can send emails
Has settings for SSL certs/key

Runs Flask + Gunicorn underneath

Has some security settings for exposing config/stacktrace/hostname in the web-interface

Can filter dags by owner/group: e.g. customer master and KPIs on the same Airflow server.

Can set default orientation of DAGs.

FAB/RBAC? Who are they?

navbar_color, how cute, should be pink.

werkzeug reverse proxy

can have `analytics_tool` within the AF web interface.

### Email
`email_backend`

### sentry

nice I guess.

### Celery

standard celery stuff

### Dask

What is this pokémon?

### scheduler

Looks for DAG-files every 5 minutes by default

### LDAP

### mesos
What is mesos?

Alright, looks like some kind of a distributed task runner, moving on.

Wow.. it mentions Docker. [It's the future](https://circleci.com/blog/its-the-future/).

### Kerberos

Something Greek, scary, and auth-related.

### Github_enterprise

### Elastic search

for logging, integrates with Kibana as well.


### Kubernetes

Ok, is the zoo complete now?  Nope, there is also GCP.

## Tutorial

https://airflow.apache.org/docs/stable/tutorial.html

A bunch of on-success, on-failure, on-sla-miss callbacks.

BashOperator

documentation in text/Markdown/rst/json/yaml, nice.

Jinja-templated command

- macros
- params

`t1 >> [t2, t3]` a cool way to define dependency of tasks.

Tasks run in different context from context of DAG-definition. XCom is a feature for cross-task communication. DAG should be fast: seconds, not minutes. The data processing should be elsewhere.

`default_args` are shared between created tasks, can be overriden.
Can specify `email_on_failure`, `retry_delay`, `sla`, etc. Could be used to distinguish production from development environments.

Templates are pretty powerful and flexible, most useful directive is `{{ ds }}` for today's datestamp.

commands can reference files whose pathes are relative to the DAG file.

### PUSH Sidetrack to macros

user_defined_macros are an option

dash/nodash timestamps plethora

{{ dag }} itself, task, instances, etc.

nes.ted.ness is supported in JSON from Airflow's UI

time/datetime/uuid/random
datetime_diff_for_humans
ds_add

`airflow.macros.hive.closest_ds_partition` closest date

### POP

DAG/tasks support formatted documentation

A bunch of ways to specify dependencies

Test script by running: `python ~/airflow/dags/tutorial.py`


## Concepts

### DAGs

A single logical workflow. Don't care about what are A, B, and C tasks. Only their order, and how they should be done. A bold promise, let's see if this abstraction is too leaky.
`DAG_FOLDER`

### Scope

DAGs are read from module `globals()`. A pattern: hide a sub-DAG in a function.

### Default Arguments

Saves time on typing for operators' setup.

### Context Manager

DAGs can be context managers. y tho? Ok, I guess for DAGs definition at runtime.

### DAG Runs

DAG and its task instances with a specific `execution_date`. Spawned by Airflow scheduler usually. Multiple dagruns can be in progress, e.g. for 2 different `execution_dates`.


### `execution_date`
Logical datetime of a DAG and its tasks. For example: reimporting stuff from 3 months ago.

### Operators

Define what gets done. Usually atomic. If operators share data, combine them into a single operator. Otherwise use `XComs`.
Act as blueprints for tasks.

* BashOperator - executes a bash command
* PythonOperator - calls an arbitrary Python function
* EmailOperator - sends an email
* SimpleHttpOperator - sends an HTTP request
* MySqlOperator, SqliteOperator, PostgresOperator, MsSqlOperator, OracleOperator, JdbcOperator, etc. - executes a SQL command
* Sensor - an Operator that waits (polls) for a certain time, file, database row, S3 key, etc…
* DockerOperator
* HiveOperator
* S3FileTransformOperator
* PrestoToMySqlTransfer
* SlackAPIOperator

### DAG Assignment

explicitly/deferred/inferred

### Bitshift Composition

Syntactic sugar for DAG definition:  `op1 >> [op2, op3] >> op4`

### Relationship Builders

Something like itertools/functools for operators.

* `cross_downstream([op1, op2, op3], [op4, op5, op6])`
* `op1 >> op2 >> op3 >> op4 >> op5` -> `chain(op1, op2, op3, op4, op5)`

### Tasks

Operator is instantiated with specific values, task becomes a node in DAG.

### Tasks Instances

(DAG, task, point in time), have status: 'running', 'success', etc.


### Task Lifecycle

* success
* running
* failed
* skipped
* rescheduled
* retry
* queued
* no status

### Happy Flow

No status -> Scheduled -> Queued -> Running -> Success

Black border in UI means scheduled run, non-bordered is manual.

### Workflow Terms

DAG, DAG Run, Operator, Task, Task Instance, execution_date

### Additional Functionality

#### Hooks

use connections defined in config, keep info in metadata db

#### Pools

limit the execution parallelism, default pool with 128 slots, operators can be assigned to pool, with pool parameter `parameter_weight`, gets summed across the whole downstream branch.

#### Connections

define in UI, a better version of `setup_secrets` + util.connections, basic load balancing with connections to the same resource sharing `conn_id`
`get_connection()` method on `BaseHook`.
`PostgresHook` uses `postgres_default`.

#### Queues

Celery-specific
`queue` is a an a
`celery` -> `default_queue`

`airflow worker -q foo,bar` command to start a worker connected to queues `foo` and `bar`.


#### XComs
cross-communication, exchange pickles via push/pull.
Keeps history, can be used in templates.

In Operator definitions
`xcom_push=True` to push
`provide_context=True` to get task instance and pull xcom.

> if a task returns a value (either from its Operator’s execute() method, or from a PythonOperator’s python_callable function), then an XCom containing that value is automatically pushed.

#### Variables

Can be added via `Admin -> Variables`, code, or cli. Can be JSON. An aqlachemy model. Can be used in jinja templates and even JSON-deserialized.

`AIRFLOW_VAR_FOO`

#### Branching:
`BranchPythonOperator`, doesn't play well with `depends_on_past=True`.


#### SubDAGs

Can store multiple dependencies of a task in a DAG, should contain a factory method.

* `parent.child` naming convention.
* must have a schedule
* avoid `depends_on_past=True`
* common to use `SequentialExecutor`

#### SLAs

Records and email SLA misses, disable with `check_slas=False`

#### Trigger Rules

> default value for `trigger_rule` is `all_success` and can be defined as “trigger this task when all directly upstream tasks have succeeded”

#### Zombies & Undeads

Tasks are instructed to verify their state as part of the heartbeat routine, and terminate themselves upon figuring out that they are in this “undead” state.

#### Cluster Policy

A policy of mutating tasks' attributes.

#### Documentation & Notes

A variety of ways to set rich documentation, can be generated dynamically for tasks that are build dynamically from config.

#### Jinja Templating

Can pass env variables to `BashOperator`.

#### Packaged DAGs

zipped DAGs

#### `.airflowignore`

enough said
