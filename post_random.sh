#!/bin/sh
# Shell script for populating a database
# First argument is for the input file with the data
# Second argument is for the specific route

PROGNAME=$0
usage() {
  cat << EOF >&2
Usage: $PROGNAME [-f <file>] [-r <route>]

-f <file>: File with random data
-r </route>: POST route for cURL

EOF
  exit 1
}

unset name
route=default_route file=default_file 
while getopts 'f:r:' o; do
  case $o in
    (f) file=$OPTARG;;
    (r) route=$OPTARG;;
    (*) usage
  esac
done
if [ $OPTIND -eq 1 ]; then usage; exit 2; fi
shift $((OPTIND-1))

jq -c '.[]' $file | while read line; do
    curl --header "Content-Type: application/json" \
    --request POST \
    --data $line \
    $HOST$route 
done
