 #!/bin/bash
 
RSPACE_URL="my url for RSpace/api/v1"
API_KEY="set this key"
targetFolderId="a folder id to put document in"

## step 1
for file in *.txt; do
  echo "uploading $file  to $RSPACE_URL ..."
  
  ## step 2
  filename=$(basename $file)
  
  ## step 3
  value=`cat $file`
  
  ## step 4
  jq -n --arg fieldContent "$value" --arg f "$filename" --arg targetFolder "$targetFolderId"\
  '{name: $f, tags: "API,example", parentFolderId: $targetFolder, fields: [ {content: $fieldContent}]}' > content-tmp.txt
  
  ## step 5     
  sed -i -e 's:\\n:<br/>:g' content-tmp.txt
  
  ## step 6
  curl -X POST -H "content-type: application/json" -H "apiKey:$API_KEY" -d @content-tmp.txt "$RSPACE_URL/documents"
  
  ## step 7
  rm content-tmp.txt
  rm content-with-html-newlines.txt
done
