#!/usr/bin/env bash

for var in PROJECT; do
    if [[ -z "${!var:-}" ]];
    then
        echo "You need to provide a value for env variable $var"
        exit 1
    fi
done

for instance in $(seq 1 3); do
    echo "Starting neo4j-enterprise-causal-cluster-1-core-vm-$instance"
    gcloud compute --project "$PROJECT" ssh --zone "us-central1-a" "neo4j-enterprise-causal-cluster-1-core-vm-$instance" --command "sudo systemctl start neo4j"
done
