#!/bin/bash

bq --location=US extract \
    --destination_format CSV \
    --field_delimiter , \
    --print_header \
    'staging-btc-etl:crypto_bitcoin.blocks' \
    'gs://staging-btc-etl-temp/blocks/blocks-*.csv'
