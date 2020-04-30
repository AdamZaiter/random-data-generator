#!/bin/sh
# Shell script for populating a database
# First argument is for the input file with the data
# Second argument is for the specific route

jq -c '.[]' $1 | while read i; do
    curl --header "Content-Type: application/json" \
    --request POST \
    --data $i \
    $HOST/$2 
  done
