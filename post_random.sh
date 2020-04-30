#!/bin/sh
# Shell script for populating a database
# First argument is for the specific route

jq -c '.[]' random_data.json | while read i; do
    curl --header "Content-Type: application/json" \
    --request POST \
    --data $i \
    $HOST/$1 
  done
