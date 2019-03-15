#!/bin/bash 

LOCATION=us-central1

echo "Upload DAGs, code and queries..."
BUCKET=$(gcloud composer environments describe airflow --location $LOCATION --format="get(config.dagGcsPrefix)")
gsutil rsync -d -r dags/bigquery/ $BUCKET/bigquery/

for dag in $(ls dags/dag_*); do
    gcloud composer environments storage dags import \
        --environment airflow \
        --location $LOCATION \
        --source $dag
done
