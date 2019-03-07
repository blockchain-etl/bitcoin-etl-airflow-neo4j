#!/bin/bash

for file in $(ls bigquery/*.sql); do
    TABLE="$(basename $file .sql)"
    bq --location=US extract \
        --destination_format CSV \
        --field_delimiter , \
        --print_header \
        'staging-btc-etl:crypto_bitcoin.'$TABLE \
        "gs://staging-btc-etl-temp/$TABLE/$TABLE-*.csv"
done
