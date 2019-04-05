#!/usr/bin/env bash

for var in PROJECT; do
    if [[ -z "${!var:-}" ]];
    then
        echo "You need to provide a value for env variable $var"
        exit 1
    fi
done

IMPORT_FOLDER=/var/lib/neo4j/import


DUMP_CMD="sudo rm -f /tmp/bitcoin.dump && sudo -u neo4j neo4j-admin dump --database=bitcoin.db --to=/tmp/bitcoin.dump"
LOAD_CMD="sudo -u neo4j rm -rf /var/lib/neo4j/data/databases/graph.db && sudo -u neo4j neo4j-admin load --from=/tmp/bitcoin.dump --database=graph.db"

echo "Dumping db in LEADER"
gcloud compute --project "$PROJECT" ssh --zone "us-central1-a" "neo4j-enterprise-causal-cluster-1-core-vm-1" --command "$DUMP_CMD"
echo "Loading db in LEADER"
gcloud compute --project "$PROJECT" ssh --zone "us-central1-a" "neo4j-enterprise-causal-cluster-1-core-vm-1" --command "$LOAD_CMD"

gcloud compute --project "$PROJECT" scp --zone "us-central1-a" "neo4j-enterprise-causal-cluster-1-core-vm-1:/tmp/bitcoin.dump" /tmp

for instance in 2 3; do
    gcloud compute --project "$PROJECT" scp --zone "us-central1-a" "/tmp/bitcoin.dump" "neo4j-enterprise-causal-cluster-1-core-vm-$instance:/tmp/"
    gcloud compute --project "$PROJECT" ssh --zone "us-central1-a" "neo4j-enterprise-causal-cluster-1-core-vm-$instance" --command "$LOAD_CMD"
done

