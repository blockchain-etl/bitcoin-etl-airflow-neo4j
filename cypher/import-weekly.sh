#!/bin/bash
set -e

BUCKET="staging-btc-etl-temp"
GS_URL="http://storage.googleapis.com/$BUCKET"
CYPHER_CMD="cypher-shell -u neo4j -p $NEO_PASS -a $NEO_ADDRESS "

# Create indexes
cat create-indexes.cypher | $CYPHER_CMD

# Import blocks
for dataset in blocks txns outputs output_addresses inputs; do
    for bucket_file in $(gsutil ls gs://$BUCKET/$dataset); do
        BASENAME=$(echo $bucket_file|cut -d'/' -f 5)
        FILENAME=$GS_URL/$dataset/$BASENAME 
        echo "About to ingest $FILENAME"
        FILENAME=$FILENAME envsubst < load-$dataset.cypher | $CYPHER_CMD
    done
done
