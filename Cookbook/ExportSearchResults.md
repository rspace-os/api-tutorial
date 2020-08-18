# Aim

You'd like to make an export of a selection of documents, perhaps from a set of search results.
These could be a set of documents tagged with a project or grant ID for example.

# Background

Exporting a selection of items is possible in the web interface. Since 1.69.19 this is also available in the API.

This feature enables searching and listing of ELN data to be exported for governance or regulatory purposes.

This recipe is developed on MacOSX Bash but should be transferable to other Unix/Linux environments

# Software required

You'll need `curl`, `awk` and `jq`; all are readily available from package managers.

RSpace 1.69.19 or later is required - earlier versions don't support selection-based export.

# Recipe

Before starting make sure you have your [API key](https://researchspace.helpdocs.io/article/v0dxtfvj7u-rspace-api-introduction). Export your key and URL as variables, e.g.
export RSPACE_API_KEY=mykey
export RSPACE_URL=https://myresearchspace.com/api/v1

A full listing is in [ExportSearchResults.sh](ExportSearchResults.sh)

```
query=$1
format=$2

## step 1
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
## step 2 get a comma-separated list of ids
ids=$(curl -s -H "apiKey: $RSPACE_API_KEY" "$RSPACE_URL/documents?query=$query" | jq --raw-output -r '.documents | map(.id) | join(",")')
echo "Found ids to export: $ids"
## continue if we have search results
if [ -z "$ids" ] ; then
	echo "No search hits for query $query, exiting" ;
	exit 1
fi


## step 3 now we submit our export job:
jobLink=$(curl -s -X POST -H "apiKey: $RSPACE_API_KEY" "$RSPACE_URL/export/$format/selection?selections=$ids"  | jq -r '._links[0].link')

## step 4
## we can monitor the status - here we extract the statusa and percentComplete fields
stat=$(curl -s -H"apiKey: $RSPACE_API_KEY" $jobLink | jq -r '. | .status +":" + "\(.percentComplete)"')

pcComplete=$(echo $stat | awk -F ":" '{print $2}')
status=$(echo $stat | awk -F ":" '{print $1}')

## step 5 iterate and sleep 5 seconds until COMPLETED
while [ "$status" != "COMPLETED" ] ; do
 echo "$status: Percent complete: $pcComplete, sleeping 5s"
 sleep 5
 stat=$(curl -s -H"apiKey: $RSPACE_API_KEY" $jobLink | jq -r '. | .status +"|" + "\(.percentComplete)"')

 pcComplete=$(echo $stat | awk -F "|" '{print $2}')
 status=$(echo $stat | awk -F "|" '{print $1}')
done
## step 6 get size and download link
data=$(curl -s -H "apiKey: $RSPACE_API_KEY" $jobLink | jq -r '. | "\(.result.size)" + "|" + ._links[0].link')
downloadLink=$(echo $data | awk -F "|" '{print $2}')
size=$(echo $data | awk -F "|" '{print $1}')
echo "Completed, size is $size bytes".
echo "Download link is $downloadLink"
echo "Use this command to download:"

## step 7
## print out the command to actually download
fileName=$(echo $downloadLink | awk -F "/" '{print $NF}')
echo "curl -s -H\"apiKey: \$RSPACE_API_KEY\" $downloadLink -o $fileName"
```

# Explanation

This script makes heavy use of `curl`, `jq` and `awk` commands. 

1. Here we perform simple argument validation to ensure that search term is present, and, if an export format is selected, that it's a valid choice.
2. Now we perform a simple search using `/document?query=` endpoint. This searches globally all over RSpace documents. 
If there's no search hits, we exit here. We format the search response into a comma-separated list of ids suitable for passing to export command.
3. We submit the export job. This will perform some checking on the server - it can take a while to return, if you are exporting 000s of items.
4. We get a 'Job' response, hopefully it will be in the 'STARTING' phase.
5. We iterate and poll for job status until it is completed.
6. Once completed, we extract the download link to get hold of the archive. We don't download it automatically as you might want to check the size of the download.
7. The script finishes by printing out the download command.

# Variations and enhancements

There are various ways this script could be modified and enhanced, e.g. by altering the polling interval or calculating it dynamically from the rate at which the `percentComplete` value changes. 

If you have a set of work or a project in a folder that you want to export, you could miss out on the searching and just start at step 3, hard-coding the folder or notebook ids you want to export. By scheduling this weekly you get make weekly snapshots of your project for auditing or regulatory purposes. 

# Conclusion

Here we showed how to develop a workflow capability to search and download content from RSpace in archive format. From here, the archive  could be sent to a backup system or a research data repository.