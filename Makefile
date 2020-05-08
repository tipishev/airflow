export AIRFLOW_HOME=./airflow

venv:
	virtualenv -p python3.6 --no-site-packages ./venv

requirements: venv                                
	./venv/bin/pip install -r requirements.txt

# initdb:
#         . venv/bin/activate && airflow initdb

upgradedb:
	. venv/bin/activate && airflow upgradedb

webserver:
	. venv/bin/activate && airflow webserver -p 8080

scheduler:
	. venv/bin/activate && airflow scheduler
