#!/bin/bash

for file in $(ls *.sql); do
    TABLE="$(basename $file .sql)"
    QUERY="$(cat $file | tr "\n" " ")"
    bq --location=US query \
        --destination_table "staging-btc-etl:crypto_bitcoin.$TABLE" \
        --replace \
        --use_legacy_sql=false \
        "$QUERY"
done
