#!/bin/bash 

LOCATION=us-central1

# Set variables
declare -A config
config["NEO4J_USER"]=neo4j
config["NEO4J_PASSWORD"]=$NEO_PASSWORD
config["NEO4J_URI"]=$NEO_URI

echo "Setting variables"...
for  key in ${!config[@]}; do
    gcloud composer environments run airflow variables \
        --location $LOCATION \
        -- --set ${key} ${config[${key}]}
done

echo "Changing config parameters..."
gcloud composer environments update airflow \
    --location $LOCATION \
    --update-airflow-configs=scheduler-catchup_by_default=False


echo "Upload requirements.txt.."
./generate-composer-requirements.sh
gcloud composer environments update airflow \
    --update-pypi-packages-from-file requirements.txt \
    --location $LOCATION 

