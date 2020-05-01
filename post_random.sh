#!/bin/sh
# Shell script for populating a database with random users

PROGNAME=$0
usage() {
  cat << EOF >&2
Usage: $PROGNAME [-f <file>] [-r <route>]

-f <file>: File with random data
-r </route>: POST route for cURL

EOF
  exit 1
}

route=''
file='' 

while getopts 'f:r:' o; do
  case $o in
    (f) file=$OPTARG;;
    (r) route=$OPTARG;;
    (*) usage
  esac
done

if [ "$#" -ne 4 ]; then
      echo "You must enter exactly 2 command line arguments";
      usage;
      exit 2;
fi

jq -c '.[]' $file | while read data; do
    curl --header "Content-Type: application/json" \
    --request POST \
    --data $data \
    $HOST$route 
done
