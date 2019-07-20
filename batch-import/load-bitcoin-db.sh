#!/usr/bin/env bash
set -e

for var in PROJECT DUMPFILEURI INSTANCE; do
    if [[ -z "${!var:-}" ]];
    then
        echo "You need to provide a value for env variable $var"
        exit 1
    fi
done

IMPORT_FOLDER=/var/lib/neo4j/import


LOAD_CMD="sudo -u neo4j rm -rf /var/lib/neo4j/data/databases/graph.db && sudo -u neo4j neo4j-admin load --from=/tmp/bitcoin.dump --database=graph.db"
SSH_CMD="gcloud compute --project $PROJECT ssh --zone us-central1-a"

echo "$(date -Iseconds) Downloading dump from bucket to neo4j-enterprise-causal-cluster-1-core-vm-$INSTANCE"
$SSH_CMD "neo4j-enterprise-causal-cluster-1-core-vm-$INSTANCE" --command "rm /tmp/bitcoin.dump && gsutil cp $DUMPFILEURI /tmp/bitcoin.dump"
echo "$(date -Iseconds) Loading dump from tmp directory to the DB in neo4j-enterprise-causal-cluster-1-core-vm-$INSTANCE"
$SSH_CMD "neo4j-enterprise-causal-cluster-1-core-vm-$INSTANCE" --command "$LOAD_CMD"

