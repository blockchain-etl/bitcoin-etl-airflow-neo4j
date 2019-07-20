#!/usr/bin/env bash
set -e

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
SSH_CMD="gcloud compute --project $PROJECT ssh --zone us-central1-a"

echo "$(date -Iseconds) Dumping db in LEADER"
$SSH_CMD "neo4j-enterprise-causal-cluster-1-core-vm-1" --command "$DUMP_CMD"
echo "$(date -Iseconds) Loading db in LEADER"
$SSH_CMD "neo4j-enterprise-causal-cluster-1-core-vm-1" --command "$LOAD_CMD"

$SSH_CMD "neo4j-enterprise-causal-cluster-1-core-vm-1" --command "gsutil cp /tmp/bitcoin.dump gs://$PROJECT/dumps/bitcoin.dump"

for instance in 2 3; do
    echo "$(date -Iseconds) Downloading dump from bucket to neo4j-enterprise-causal-cluster-1-core-vm-$instance"
    $SSH_CMD "neo4j-enterprise-causal-cluster-1-core-vm-$instance" --command "gsutil cp gs://$PROJECT/dumps/bitcoin.dump /tmp/bitcoin.dump"
    echo "$(date -Iseconds) Downloading dump from bucket to neo4j-enterprise-causal-cluster-1-core-vm-$instance"
    $SSH_CMD "neo4j-enterprise-causal-cluster-1-core-vm-$instance" --command "$LOAD_CMD"
done

