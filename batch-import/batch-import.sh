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

function create_tables {
    for file in $(ls bigquery/*.sql); do
        TABLE="$(basename $file .sql)"
        QUERY="$(cat $file | tr "\n" " ")"

        echo "  Creating aux table $TABLE"
        bq --location=US query \
            --destination_table "$PROJECT:crypto_bitcoin.$TABLE" \
            --replace \
            --use_legacy_sql=false \
            --format none \
            "$QUERY"
    done
}

function export_tables {
    for file in $(ls bigquery/*.sql); do
        TABLE="$(basename $file .sql)"
        FOLDER="gs://$PROJECT/batch_import/$TABLE"
        gsutil rm ${FOLDER}/** || true
        echo "  Exporting table $TABLE to bucket $FOLDER"
        bq --location=US extract \
            --compression GZIP \
            --destination_format CSV \
            --field_delimiter , \
            --noprint_header \
            --format none \
            "$PROJECT:crypto_bitcoin.$TABLE" \
            "$FOLDER/$TABLE-*.csv.gz"
    done
}

function download_datasets {
    mkdir /tmp/datasets
    gsutil cp -r gs://staging-btc-etl/batch_import/* /tmp/datasets
    sudo chown -R neo4j:adm /tmp/datasets
    sudo -u neo4j mv /tmp/datasets/* $IMPORT_FOLDER
}

function run_import {
    neo4j-admin import --nodes="addresses_header.csv,addresses/addresses-.*" \
        --nodes="blocks_header.csv,blocks/blocks-.*" \
        --nodes="outputs_header.csv,outputs/outputs-.*" \
        --relationships:next="block_to_block_header.csv,block_to_block/block_to_block-.*" \
        --relationships:at="txns_to_blocks_header.csv,txns_to_blocks/txns_to_blocks-.*" \
        --relationships:received="outputs_to_txns_header.csv,outputs_to_txns/outputs_to_txns-.*" \
        --relationships:owned="outputs_to_addresses_header.csv,outputs_to_addresses/outputs_to_addresses-.*" \
        --relationships:sent="inputs_to_txns_header.csv,inputs_to_txns/inputs_to_txns-.*"
}

# create_tables
# export_tables
# download_datasets
run_import

