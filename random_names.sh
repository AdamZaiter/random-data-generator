#!/bin/sh
# Shell script for generating a random first name,
# middle name and last name

PROGNAME=$0
usage() {
  cat << EOF >&2
Usage: $PROGNAME [-n <num>] [-o <filepath>]

-n <num>: num of iterations (5 names per iteration)
-o <filepath>: output file path

EOF
  exit 1
}

num=0
outfile=''

while getopts 'n:o:' o; do
  case $o in
    (n) num=$OPTARG;;
    (o) outfile=$OPTARG;;
    (*) usage
  esac
done

if [ "$#" -ne 4 ]; then
      echo "You must enter exactly 2 command line arguments";
      usage;
      exit 2;
fi

for i in $(seq 1 $num);
  do 
    $(curl -s 'https://www.behindthename.com/random/random.php?number=2&sets=5&gender=both&surname=&randomsurname=yes&norare=yes&usage_eng=1' | 
      grep -Po '/name/.*?">.*?</a>' |sed 's/.*">//g' |
      sed 's/<\/a>//g'  |
      xargs -n3 >> $outfile)
  done;
echo "Names saved to $outfile"
