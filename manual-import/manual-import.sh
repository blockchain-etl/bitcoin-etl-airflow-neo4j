#!/usr/bin/env bash

# Load 2009
# ./create-tables.sh 2009-01-01 YEAR

# Load 2010 to 2013
#for year in $(seq 2010 2013); do
#    for month in $(seq 1 12); do
for year in $(seq 2010 2013); do
    for month in $(seq -f "%02g" 1 12); do
        START_DATE="${year}-${month}-01"
        echo "Import for $START_DATE with interval MONTH starting at $(date)"
        START_DATE=$START_DATE INTERVAL=MONTH ./create-tables.sh
        START_DATE=$START_DATE ./tables-to-bucket.sh
        START_DATE=$START_DATE ./load-into-neo4j.sh
    done
done