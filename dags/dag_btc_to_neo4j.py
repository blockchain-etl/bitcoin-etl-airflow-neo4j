"""This dag ingest bitcoin blockchain into Neo4J"""

import logging
from datetime import datetime, timedelta

from airflow import macros
from airflow.contrib.operators.bigquery_operator import BigQueryOperator
from airflow.contrib.operators.bigquery_to_gcs import BigQueryToCloudStorageOperator
from airflow.models import DAG, Variable
from airflow.operators.python_operator import PythonOperator
from google.cloud import storage
from neo4j import GraphDatabase

DEFAULT_ARGS = {
    'owner': 'airflow',
    'depends_on_past': True,
    'start_date': datetime(2009, 1, 3),
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}
NEO4J_URI = Variable.get('NEO4J_URI')
NEO4J_USER = Variable.get('NEO4J_USER')
NEO4J_PASSWORD = Variable.get('NEO4J_USER')

BUCKET = 'staging-btc-etl-temp'

DESTINATION_FOLDER_TEMPLATE = 'gs://{bucket}'.format(bucket=BUCKET) + \
                              '/neo4j_import/{{macros.ds_format(ds, "%Y-%m-%d", "%Y/%m/%d")}}/' \
                              '{element}/{element}-*.csv'


def load_into_neo4j(ds, element):
    neo4j_driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))
    with neo4j_driver.session() as session:
        storage_client = storage.Client()
        bucket = storage_client.get_bucket(BUCKET)
        date_folder = macros.ds_format(ds, "%Y-%m-%d", "%Y/%m/%d")
        prefix = 'neo4j_import/{date_folder}/{element}/'.format(date_folder=date_folder, element=element)
        for element in bucket.list_blobs(prefix=prefix):
            logging.info("File found un bucket: ", element)


def build_dag():
    """Build DAG."""
    dag = DAG('btc_to_neo4j',
              schedule_interval=None,
              default_args=DEFAULT_ARGS,
              catchup=False)

    # NOTE: It is import to keep elements of this list in this order since it is required later when loading data
    blockchain_elements = ['blocks', 'txns', 'outputs', 'output_addresses', 'inputs']
    load_dependency = None
    for element in blockchain_elements:
        table = 'crypto_bitcoin.{element}'.format(element=element)
        bigquery_to_daily_table_task = BigQueryOperator(
            task_id='{element}_to_daily_table'.format(element=element),
            sql='bigquery/{element}.sql'.format(element=element),
            destination_dataset_table=table,
            write_disposition='WRITE_TRUNCATE',
            use_legacy_sql=False,
            dag=dag
        )

        destination_pattern = DESTINATION_FOLDER_TEMPLATE.format(element=element)
        table_to_bucket_task = BigQueryToCloudStorageOperator(
            task_id='{element}_table_to_bucket'.format(element=element),
            source_project_dataset_table=table,
            destination_cloud_storage_uris=[destination_pattern],
            export_format='csv',
            field_delimiter=',',
            print_header=True,
            dag=dag
        )

        load_into_neo4j_task = PythonOperator(
            task_id="load_{element}_into_neo4j".format(element=element),
            python_callable=lambda ds, **kwargs: load_into_neo4j(destination_pattern),
            provide_context=True,
            dag=dag
        )

        bigquery_to_daily_table_task >> table_to_bucket_task >> load_into_neo4j_task

        # Make sure that we load data in Neo4J in right order
        if load_dependency is not None:
            load_dependency >> load_into_neo4j_task

        load_dependency = load_into_neo4j_task

    return dag


the_dag = build_dag()
