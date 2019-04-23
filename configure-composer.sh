#!/bin/bash

for var in NEO_PASSWORD NEO_IP PROJECT ; do
    if [[ -z "${!var:-}" ]];
    then
        echo "You need to provide a value for env variable $var"
        exit 1
    fi
done

LOCATION=us-central1
# Set variables
declare -A config
config["NEO4J_USER"]=neo4j
config["NEO4J_PASSWORD"]=$NEO_PASSWORD
config["NEO4J_URI"]="bolt+routing://$NEO_IP:7687"
config["BUCKET"]=$PROJECT

echo "Setting variables"...
for  key in ${!config[@]}; do
    gcloud composer environments run airflow variables \
        --project $PROJECT \
        --location $LOCATION \
        -- --set ${key} ${config[${key}]}
done

echo "Limit number of concurrent tasks ingesting into Neo4J..."
gcloud composer environments run airflow pool \
   --project $PROJECT \
   --location $LOCATION \
   -- --set neo4j_slot 1 "Limit tasks importing to Neo4J to just 1"

echo "Changing config parameters..."
gcloud composer environments update airflow \
    --project $PROJECT \
    --location $LOCATION \
    --update-airflow-configs=scheduler-catchup_by_default=False


echo "Upload requirements.txt.."
./generate-composer-requirements.sh
gcloud composer environments update airflow \
    --project $PROJECT \
    --update-pypi-packages-from-file requirements.txt \
    --location $LOCATION 

