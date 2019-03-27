#!/usr/bin/env bash

set -e

for var in PROJECT START_DATE NEO_PASSWORD NEO_HOST; do
    if [[ -z "${!var:-}" ]];
    then
        echo "You need to provide a value for env variable $var"
        exit 1
    fi
done


GS_URL="http://storage.googleapis.com/$PROJECT"
CYPHER_CMD="cypher-shell -u neo4j -p $NEO_PASSWORD -a bolt+routing://$NEO_HOST:7687 "

# Import tables
for dataset in output_addresses inputs; do
    for bucket_file in $(gsutil ls gs://$PROJECT/manual_import/${START_DATE//-//}/$dataset/); do
        BASENAME=$(echo $bucket_file|cut -d'/' -f 9)
        URI="$GS_URL/manual_import/${START_DATE//-//}/$dataset/$BASENAME"
        echo "  $(date -Iseconds): About to ingest $URI into neo4j"
        python3 render_template.py --template cypher/create-$dataset.cypher --set uri=$URI | $CYPHER_CMD
    done
done
