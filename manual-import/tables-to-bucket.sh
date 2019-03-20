#!/bin/bash

for file in $(ls bigquery/*.sql); do
    TABLE="$(basename $file .sql)"
    FOLDER="gs://staging-btc-etl-temp/$TABLE"
    gsutil rm ${FOLDER}/**
    bq --location=US extract \
        --destination_format CSV \
        --field_delimiter , \
        --print_header \
        'staging-btc-etl:crypto_bitcoin.'$TABLE \
        "$FOLDER/$TABLE-*.csv"
done
