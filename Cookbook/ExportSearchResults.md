# Aim

You'd like to make an export of a selection of documents, perhaps from a set of search results.
These could be a set of documents tagged with a project or grant ID for example.

# Background

Exporting a selection of items is possible in the web interface. Since 1.69.19 this is also available in the API.

This feature enables searching and listing of ELN data to be exported for governance or regulatory purposes.

This recipe is developed on MacOSX Bash but should be transferable to other Unix/Linux environments

# Software required

You'll need `curl` and `jq`; both are readily available from package managers.

# Recipe

Before starting make sure you have your [API key](https://researchspace.helpdocs.io/article/v0dxtfvj7u-rspace-api-introduction). Export your key and URL as variables, e.g.
export RSPACE_API_KEY=mykey
export RSPACE_URL=https://myresearchspace.com/api/v1

#!/bin/bash
## get a search term as argument to the script
query=$1
## get a comma-separated list of ids
ids=$(curl -H"apiKey: $RSPACE_API_KEY" "$RSPACE_URL/documents?query=$query" | jq --raw-output -r '.documents | map(.id) | join(",")')

## continue if we have search results
if [ -z "$ids" ] ; then
	echo "No search hits for query $query, exiting" ;
	exit 1
fi

## now we submit our export job:
jobLink=$(curl -X POST -H "apiKey: $RSPACE_API_KEY" "$RSPACE_URL/export/html/selection?selections=$ids"  | jq -r '._links[0].link')

## we can monitor the status
stat=$(curl -H"apiKey: $RSPACE_API_KEY" $jobLink | jq -r '. | .status +":" + "\(.percentComplete)"')

pcComplete=$(echo $stat | awk -F ":" '{print $2}')
status=$(echo $stat | awk -F ":" '{print $1}')



