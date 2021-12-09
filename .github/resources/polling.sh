#!/bin/bash

declare -i duration=1
declare hasUrl=""
declare endpoint

usage() {
    cat <<END
    polling.sh [-i] [-h] endpoint
    
    Report the health status of the endpoint
    -i: include Uri for the format
    -h: help
END
}

while getopts "ih" opt; do 
  case $opt in 
    i)
      hasUrl=true
      ;;
    h) 
      usage
      exit 0
      ;;
    \?)
     echo "Unknown option: -${OPTARG}" >&2
     exit 1
     ;;
  esac
done

shift $((OPTIND -1))

if [[ $1 ]]; then
  endpoint=$1
else
  echo "Please specify the endpoint."
  usage
  exit 1 
fi 


healthcheck() {
    declare url=$1
    result=$(curl --http2 -i $url 2>/dev/null | grep "HTTP/[12][12\.]*")
    echo $result
}

for n in 1..100 {
   result=`healthcheck $endpoint` 
   declare status
   if [[ -z $result ]]; then 
      status="N/A"
   else
      status=${result:9:3}
   fi 
   timestamp=$(date "+%Y%m%d-%H%M%S")
   if [[ -z $hasUrl ]]; then
     echo "$timestamp | $status "
     if [[ $status == 0 ]]; then
        exit 0
     fi
   else
     echo "$timestamp | $status | $endpoint " 
   fi 
   sleep $duration
}
exit 1
