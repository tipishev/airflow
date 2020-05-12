export AIRFLOW_HOME=./airflow

venv:
	virtualenv -p python3.6 --no-site-packages ./venv

requirements: venv                                
	./venv/bin/pip install -r requirements.txt

initdb:
	sudo -u postgres createuser airflow
	sudo -u postgres createdb airflow
	sudo adduser airflow
	. venv/bin/activate && airflow initdb

dropdb:
	sudo -u postgres dropdb airflow
	sudo -u postgres dropuser airflow
	sudo deluser airflow

upgradedb:
	. venv/bin/activate && airflow upgradedb

webserver:
	. venv/bin/activate && airflow webserver -p 8080

scheduler:
	. venv/bin/activate && airflow scheduler

add_to_systemd:
	sudo ln -s systemd/airflow-webserver.service /lib/systemd/system/airflow-webserver.service
	sudo ln -s systemd/airflow-scheduler.service /lib/systemd/system/airflow-scheduler.service
	sudo systemctl daemon-reload  # to read the new service definitions
	sudo systemctl start airflow-webserver.service
	sudo systemctl start airflow-scheduler.service
	sudo systemctl enable airflow-webserver.service
	sudo systemctl enable airflow-scheduler.service
	sudo systemctl status airflow-webserver

TEST_DAG_ID := my_test_dag
TEST_TASK_ID := my_first_operator_task
TEST_EXECUTION_DATE := 05-08T14:12:16.494309+00:00
test:
	. venv/bin/activate && airflow test -pm\
		$(TEST_DAG_ID) $(TEST_TASK_ID) $(TEST_EXECUTION_DATE)
