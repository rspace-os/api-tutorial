#!/bin/bash
## get a search term as argument to the script
## To run this script export your API key and URL as environment variables, e.g.
## export RSPACE_URL=https://myrspace.com/api/v1
## export RSPACE_API_KEY=myapikey
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
ids=$(curl -s -H "apiKey: $RSPACE_API_KEY" "$RSPACE_URL/documents?query=$query" | jq --raw-output -r '.documents | map(.id) | join(",")')
echo "Found ids to export: $ids"
## continue if we have search results
if [ -z "$ids" ] ; then
	echo "No search hits for query $query, exiting" ;
	exit 1
fi


## now we submit our export job:
jobLink=$(curl -s -X POST -H "apiKey: $RSPACE_API_KEY" "$RSPACE_URL/export/$format/selection?selections=$ids"  | jq -r '._links[0].link')

## we can monitor the status - here we extract the statusa and percentComplete fields
stat=$(curl -s -H"apiKey: $RSPACE_API_KEY" $jobLink | jq -r '. | .status +":" + "\(.percentComplete)"')

pcComplete=$(echo $stat | awk -F ":" '{print $2}')
status=$(echo $stat | awk -F ":" '{print $1}')

## now, iterate and sleep 5 seconds until COMPLETED
while [ "$status" != "COMPLETED" ] ; do
 echo "$status: Percent complete: $pcComplete, sleeping 5s"
 sleep 5
 stat=$(curl -s -H"apiKey: $RSPACE_API_KEY" $jobLink | jq -r '. | .status +"|" + "\(.percentComplete)"')

 pcComplete=$(echo $stat | awk -F "|" '{print $2}')
 status=$(echo $stat | awk -F "|" '{print $1}')
done
## get size and download link
data=$(curl -s -H "apiKey: $RSPACE_API_KEY" $jobLink | jq -r '. | "\(.result.size)" + "|" + ._links[0].link')
downloadLink=$(echo $data | awk -F "|" '{print $2}')
size=$(echo $data | awk -F "|" '{print $1}')
echo "Completed, size is $size bytes".
echo "Download link is $downloadLink"
echo "Use this command to download:"

## print out the command to actually download
fileName=$(echo $downloadLink | awk -F "/" '{print $NF}')
echo "curl -s -H\"apiKey: \$RSPACE_API_KEY\" $downloadLink -o $fileName"
