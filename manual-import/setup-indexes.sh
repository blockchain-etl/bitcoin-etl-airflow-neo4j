#!/usr/bin/env bash

for var in NEO_PASSWORD NEO_HOST; do
    if [[ -z "${!var:-}" ]];
    then
        echo "You need to provide a value for env variable $var"
        exit 1
    fi
done

cat ../dags/cypher/create-indexes.cypher | cypher-shell -u neo4j -p $NEO_PASSWORD -a bolt+routing://$NEO_HOST:7687