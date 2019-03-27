#!/usr/bin/env bash

for var in PROJECT NEO_PASSWORD NEO_HOST; do
    if [[ -z "${!var:-}" ]];
    then
        echo "You need to provide a value for env variable $var"
        exit 1
    fi
done


# Create all loading entries
declare -A points
ordered_dates=()

for year in $(seq 2009 2009); do
    start_of_year="$year-01-01"
    ordered_dates+=($start_of_year)
    points[$start_of_year]="YEAR"
done

# for year in $(seq 2011 2012); do
#     for month in $(seq -f "%02g" 1 12); do
#         start_of_month="${year}-${month}-01"
#         ordered_dates+=($start_of_month)
#         points[$start_of_month]="MONTH"
#     done
# done
#
# for year in $(seq 2013 2015); do
#    for week in $(seq 0 52); do
#         start_of_week=$(date -d"$year-01-01 +$(($week  * 7))days" +%Y-%m-%d)
#         ordered_dates+=($start_of_week)
#         points[$start_of_week]="WEEK"
#    done
# done

# First export all data
#for START_DATE in ${ordered_dates[@]}; do
#        echo "Import for $START_DATE with interval ${points[${START_DATE}]} starting at $(date)"
#        START_DATE=$START_DATE INTERVAL=${points[${START_DATE}]} ./create-tables.sh
#        START_DATE=$START_DATE ./tables-to-bucket.sh
#done

# First create all nodes independent of indexes
for START_DATE in ${ordered_dates[@]}; do
        echo "Import for $START_DATE with interval ${points[${START_DATE}]} starting at $(date)"
        START_DATE=$START_DATE ./create-non-linked-nodes.sh
done

# Then we create indexes
echo "Creating indexes"
./setup-indexes.sh

# Once indexes are created we link previously created nodes.
CYPHER_CMD="cypher-shell -u neo4j -p $NEO_PASSWORD -a bolt+routing://$NEO_HOST:7687 "

echo "Linking blocks together"
cat cypher/link-blocks.cypher | $CYPHER_CMD
echo "Linking transactions to blocks"
cat cypher/link-txns.cypher | $CYPHER_CMD

# Now that indexes are created and some other links also we create nodes and relationships that require extra information
for START_DATE in ${ordered_dates[@]}; do
        echo "Import for $START_DATE with interval ${points[${START_DATE}]} starting at $(date)"
        START_DATE=$START_DATE ./create-dependent-nodes.sh
done


