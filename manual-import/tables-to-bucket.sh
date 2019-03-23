#!/bin/bash

for var in PROJECT START_DATE ; do
    if [[ -z "${!var:-}" ]];
    then
        echo "You need to provide a value for env variable $var"
        exit 1
    fi
done

for file in $(ls ../dags/bigquery/*.sql); do
    TABLE="$(basename $file .sql)"
    FOLDER="gs://$PROJECT/manual_import/${START_DATE//-//}/$TABLE"
    gsutil rm ${FOLDER}/**
    echo "  Exporting table $TABLE to bucket $FOLDER"
    bq --location=US extract \
        --destination_format CSV \
        --field_delimiter , \
        --print_header \
        --format none \
        "$PROJECT:crypto_bitcoin.$TABLE" \
        "$FOLDER/$TABLE-*.csv"
done
