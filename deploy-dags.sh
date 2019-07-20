#!/bin/bash 

for var in PROJECT ; do
    if [[ -z "${!var:-}" ]];
    then
        echo "You need to provide a value for env variable $var"
        exit 1
    fi
done

LOCATION=us-central1

echo "Upload DAGs, code and queries..."
BUCKET=$(gcloud composer environments describe airflow --project $PROJECT --location $LOCATION --format="get(config.dagGcsPrefix)")
gsutil rsync -d -r dags/bigquery/ $BUCKET/bigquery/
gsutil rsync -d -r dags/cypher/ $BUCKET/cypher/

for dag in $(ls dags/dag_*); do
    gcloud composer environments storage dags import \
        --project $PROJECT \
        --environment airflow \
        --location $LOCATION \
        --source $dag
done
