#!/bin/bash

## Uploads files in a folder to the Gallery and then links them to a document
## This recipe assumes that the document you are editing has two text fields. 

## Additionally, will log file uploads in $HOME/RSPACE_LOG.txt

## The full path to the  folder you are going to upload from
## change this for the folder you are monitoring
HOME=/Users/me
FOLDER=$HOME/path/to/folder

## The id of the form used to create the document
## change this for your own form ID
FORM_ID=12345

## The id of the document you want to edit
## change  this for your document ID
DOC_ID=98765


function append_file_link {

  # get content of existing field
  doc=$(curl  "$RSPACE_URL/api/v1/documents/$DOC_ID" -H "accept: application/json" -H "apiKey: $RSPACE_API_KEY")

  ## edit the index if you want to create links in a different field
  doc_field_id=$(echo $doc | jq '.fields[1].id')
  field_content=$(echo $doc | jq --raw-output '.fields[1].content')

  ## append file link to the end of the field
  new_field_content="${field_content}<fileId=${uploaded_file_id}>"
  echo $new_field_content

  ## replace content with new content
  post_body_template='{"form":{"id":$form_id }, "fields":[{"id":$field_id, "content":$content}]}'
  post_body=$(jq -n --arg form_id "$FORM_ID" --arg content "$new_field_content" --arg field_id "$doc_field_id"  "$post_body_template")
 
  curl  -X PUT -H "content-type: application/json" -H "apiKey: $RSPACE_API_KEY" -d "$post_body" "$RSPACE_URL/api/v1/documents/$DOC_ID"
}

echo "$0 Invoked at $(date)" >> $HOME/RSPACE_LOG.txt
## iterate over files in the folder (not subfolders)
for f in $(find $FOLDER -type f -maxdepth 1 ) ; do
 echo "uploading $f"
 uploaded_file_id=$(curl -X POST "$RSPACE_URL/api/v1/files" -H "accept: application/json" -H "apiKey: $RSPACE_API_KEY" -H "Content-Type: multipart/form-data" -F "file=@$f"  | jq '.id')
 append_file_link

 ## optionally, uncomment the line below to delete the file after uploading it.
 #rm $f
done
