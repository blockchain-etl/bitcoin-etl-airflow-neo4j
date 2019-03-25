#!/usr/bin/env bash

# Create all loading entries
declare -A points
ordered_dates=()

#for year in $(seq 2009 2010); do
#    start_of_year="$year-01-01"
#    ordered_dates+=($start_of_year)
#    points[$start_of_year]="YEAR"
#done
#
#for year in $(seq 2011 2012); do
#    for month in $(seq -f "%02g" 1 12); do
#        start_of_month="${year}-${month}-01"
#        ordered_dates+=($start_of_month)
#        points[$start_of_month]="MONTH"
#    done
#done

for year in $(seq 2013 2015); do
   for week in $(seq 0 51); do
        start_of_week=$(date -d"$year-01-01 +$(($week  * 7))days" +%Y-%m-%d)
        ordered_dates+=($start_of_week)
        points[$start_of_week]="WEEK"
   done
done

# First export all data
for START_DATE in ${ordered_dates[@]}; do
        echo "Import for $START_DATE with interval ${points[${START_DATE}]} starting at $(date)"
        START_DATE=$START_DATE INTERVAL=${points[${START_DATE}]} ./create-tables.sh
        START_DATE=$START_DATE ./tables-to-bucket.sh
done

# # Then load into neo4j
# for START_DATE in ${ordered_dates[@]}; do
#         echo "Import for $START_DATE with interval ${points[${START_DATE}]} starting at $(date)"
#         START_DATE=$START_DATE ./load-into-neo4j.sh
# done
