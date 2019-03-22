"""This dag ingest bitcoin blockchain into Neo4J"""

import logging
from datetime import datetime, timedelta

import jinja2
from airflow import macros
from airflow.contrib.operators.bigquery_operator import BigQueryOperator
from airflow.contrib.operators.bigquery_table_delete_operator import BigQueryTableDeleteOperator
from airflow.contrib.operators.bigquery_to_gcs import BigQueryToCloudStorageOperator
from airflow.models import DAG, Variable
from airflow.operators.python_operator import PythonOperator
from google.cloud import storage
from neo4j import GraphDatabase

DEFAULT_ARGS = {
    'owner': 'airflow',
    'depends_on_past': True,
    'start_date': datetime(2009, 1, 3),
    'end_date': datetime(2010, 12, 31),
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}
NEO4J_URI = Variable.get('NEO4J_URI')
NEO4J_USER = Variable.get('NEO4J_USER')
NEO4J_PASSWORD = Variable.get('NEO4J_PASSWORD')

BUCKET = Variable.get('BUCKET')

DESTINATION_FOLDER_TEMPLATE = 'gs://{bucket}'.format(bucket=BUCKET) + \
                              '/neo4j_import/{{{macros.ds_format(ds, "%Y-%m-%d", "%Y/%m/%d")}}}/' \
                              '{element}/{element}-*.csv'


def load_into_neo4j(ds, **kwargs):
    element = kwargs['element']
    neo4j_driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))
    with neo4j_driver.session() as session:
        template_loader = jinja2.FileSystemLoader(searchpath='gcs/dags/cypher/')
        template_env = jinja2.Environment(loader=template_loader)
        template = template_env.get_template('load-{element}.cypher'.format(element=element))
        # Load data files
        storage_client = storage.Client()
        bucket = storage_client.get_bucket(BUCKET)
        date_folder = macros.ds_format(ds, "%Y-%m-%d", "%Y/%m/%d")
        prefix = 'neo4j_import/{date_folder}/{element}/'.format(date_folder=date_folder, element=element)
        for gs_filename in bucket.list_blobs(prefix=prefix):
            uri = 'http://storage.googleapis.com/{bucket}/{gs_filename}'.format(bucket=bucket.name,
                                                                                gs_filename=gs_filename.name)
            cypher_query = template.render(uri=uri)
            logging.info(cypher_query)
            result = session.run(cypher_query)
            logging.info("Execution of load into Neo4J returned: %s", result.summary().counters)


def backfill_blocks_in_neo4j(ds, **_):
    neo4j_driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))
    with neo4j_driver.session() as session:
        cypher_query = "MATCH (_b:Block)  WHERE date(_b.timestamp) = date('" + ds + "') " \
                       "MATCH (b:Block {height: _b.height + 1}) " \
                       "MERGE (_b)-[:next]->(b)"
        result = session.run(cypher_query)
        logging.info("Execution of backfill_blocks_into_neo4j: %s", result.summary().counters)


def build_dag():
    """Build DAG."""
    dag = DAG('btc_to_neo4j',
              schedule_interval='@daily',
              default_args=DEFAULT_ARGS,
              catchup=True)

    # NOTE: It is import to keep elements of this list in this order since it is required later when loading data
    blockchain_elements = ['blocks', 'txns', 'outputs', 'output_addresses', 'inputs']
    load_dependency = None

    for element in blockchain_elements:
        table = 'crypto_bitcoin.{element}'.format(element=element) + '_{{ds_nodash}}'
        bigquery_to_daily_table_task = BigQueryOperator(
            task_id='{element}_to_daily_table'.format(element=element),
            sql='bigquery/{element}.sql'.format(element=element),
            destination_dataset_table=table,
            write_disposition='WRITE_TRUNCATE',
            use_legacy_sql=False,
            dag=dag
        )

        filename = '{element}/{element}-*.csv'.format(element=element)
        destination_pattern = 'gs://{bucket}'.format(bucket=BUCKET) + \
                              '/neo4j_import/{{macros.ds_format(ds, "%Y-%m-%d", "%Y/%m/%d")}}/' + filename

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
            python_callable=load_into_neo4j,
            provide_context=True,
            op_kwargs={'element': element},
            pool='neo4j_slot',
            dag=dag
        )

        # NOTE: timestamps in blocks are not strictly incremental and since we query by dates it could happen
        # that we need to backfill some relations.
        # See: https://bitcoin.stackexchange.com/questions/67618/difference-between-time-and-mediantime-in-getblock
        if element == 'blocks':
            backfill_blocks_in_neo4j_task = PythonOperator(
                task_id="backfill_blocks_in_neo4j",
                python_callable=backfill_blocks_in_neo4j,
                provide_context=True,
                pool='neo4j_slot',
                dag=dag
            )
            load_into_neo4j_task >> backfill_blocks_in_neo4j_task

        delete_aux_table = BigQueryTableDeleteOperator(
            task_id='delete_{element}_table'.format(element=element),
            deletion_dataset_table=table,
            dag=dag
        )

        bigquery_to_daily_table_task >> table_to_bucket_task >> load_into_neo4j_task
        table_to_bucket_task >> delete_aux_table

        # Make sure that we load data in Neo4J in right order
        if load_dependency is not None:
            load_dependency >> load_into_neo4j_task

        load_dependency = load_into_neo4j_task

    return dag


the_dag = build_dag()
