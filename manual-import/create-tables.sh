#!/bin/bash

for var in PROJECT START_DATE INTERVAL ; do
    if [[ -z "${!var:-}" ]];
    then
        echo "You need to provide a value for env variable $var"
        exit 1
    fi
done

set -e

for file in $(ls ../dags/bigquery/*.sql); do
    TABLE="$(basename $file .sql)"
    QUERY="$(python3  render_template.py --template bigquery/$TABLE.sql --set ds=$START_DATE var.value.INTERVAL=$INTERVAL | tr "\n" " ")"

    echo "  Creating aux table $TABLE for starting date $START_DATE and interval $INTERVAL"
    bq --location=US query \
        --destination_table "$PROJECT:crypto_bitcoin.$TABLE" \
        --replace \
        --use_legacy_sql=false \
        --format none \
        "$QUERY"
done
