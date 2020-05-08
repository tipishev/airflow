from datetime import datetime
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators import MyFirstOperator, MyFirstSensor

with DAG('my_test_dag', description='Another tutorial DAG',
         schedule_interval='0 12 * * *',
         start_date=datetime(2017, 3, 20), catchup=False) as dag:

    dummy_task = DummyOperator(task_id='dummy_task')

    sensor_task = MyFirstSensor(task_id='my_sensor_task', poke_interval=30)

    operator_task = MyFirstOperator(my_operator_param='This is a test.',
                                    task_id='my_first_operator_task')

dummy_task >> sensor_task >> operator_task
