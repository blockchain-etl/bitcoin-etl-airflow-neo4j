#!/bin/bash 

for var in NEO_PASSWORD NEO_IP PROJECT ; do
    if [[ -z "${!var:-}" ]];
    then
        echo "You need to provide a value for env variable $var"
        exit 1
    fi
done

LOCATION=us-central1

echo "Create bucket..."
gsutil mb -p $PROJECT -c regional -l $LOCATION gs://$PROJECT/
echo "And make it publicly available..."
gsutil iam ch allUsers:objectViewer gs://$PROJECT

echo "Create bigquery dataset..."
bq --location=US mk --dataset \
    --project $PROJECT \
    --description "Hold auxiliar tables for Neo4J importing" \
    $PROJECT:crypto_bitcoin

echo "Create composer environment..."
gcloud composer environments create airflow \
    --project $PROJECT \
    --location us-central1 \
    --zone us-central1-a \
    --image-version composer-1.6.1-airflow-1.10.1 \
    --python-version 3

