#!/bin/bash

BUCKET="staging-btc-etl-temp"
GS_URL="http://storage.googleapis.com/$BUCKET"
CYPHER_CMD="cypher-shell -u neo4j -p $NEO_PASS -a $NEO_ADDRESS "

# Create indexes
cat create-indexes.cypher | $CYPHER_CMD

# Import blocks
for bucket_file in $(gsutil ls gs://$BUCKET/blocks); do
    BASENAME=$(echo $bucket_file|cut -d'/' -f 5)
    FILENAME=$GS_URL/blocks/$BASENAME envsubst < load-blocks.cypher | $CYPHER_CMD
done
