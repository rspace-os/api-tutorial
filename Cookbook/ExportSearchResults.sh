#!/bin/bash
## get a search term as argument to the script
query=$1
format=$2

if [ -z "$query" ] ; then
  echo "no query specified, exiting"
  exit 1
fi
if [ -z "$format" ] ; then
  echo "no format specified, defaulting to HTML"
  format=html
elif [ "$format" != "html" ] && [ "$format" != "xml" ] ; then
  echo "Invalid format $format - must be 'xml' or 'html', exiting"
  exit 1
fi
## get a comma-separated list of ids
ids=$(curl -H"apiKey: $RSPACE_API_KEY" "$RSPACE_URL/documents?query=$query" | jq --raw-output -r '.documents | map(.id) | join(",")')

## continue if we have search results
if [ -z "$ids" ] ; then
	echo "No search hits for query $query, exiting" ;
	exit 1
fi


## now we submit our export job:
jobLink=$(curl -X POST -H "apiKey: $RSPACE_API_KEY" "$RSPACE_URL/export/$format/selection?selections=$ids"  | jq -r '._links[0].link')

## we can monitor the status
stat=$(curl -H"apiKey: $RSPACE_API_KEY" $jobLink | jq -r '. | .status +":" + "\(.percentComplete)"')

pcComplete=$(echo $stat | awk -F ":" '{print $2}')
status=$(echo $stat | awk -F ":" '{print $1}')

while [ "$status" != "COMPLETED" ] ; do
 echo "$status: Percent complete: $pcComplete, sleeping 10s"
 sleep 10
 stat=$(curl -H"apiKey: $RSPACE_API_KEY" $jobLink | jq -r '. | .status +":" + "\(.percentComplete)"')

 pcComplete=$(echo $stat | awk -F ":" '{print $2}')
 status=$(echo $stat | awk -F ":" '{print $1}')

done
echo "Completed"
curl -H"apiKey: $RSPACE_API_KEY" $jobLink | jq '.'
