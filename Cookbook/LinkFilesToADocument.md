# Aim

You are collecting files in a directory - perhaps deposited there by an instrument. You'd like these to be
automatically sent to an RSpace experiment document so that they are associated with an experiment or protocol.

# Background

This recipe enables automated association of files with an experiment.

This recipe is developed on MacOSX Bash but should be transferable to other Unix/Linux environments

# Software required

You'll need `curl`, and  `jq`; both are readily available from package managers.

RSpace 1.69 or later is required. 

# Setup

In this recipe we will add files to a document that is already created. This document has two fields,
 one for manual content entry and one to hold the files we'll upload through the API. We'll also need the formID.

If your document structure is different then you can easily change the field index in the script.

# Recipe

Before starting make sure you have your [API key](https://researchspace.helpdocs.io/article/v0dxtfvj7u-rspace-api-introduction). Export your key and URL as variables, e.g.


    export RSPACE_API_KEY=mykey
    export RSPACE_URL=https://myresearchspace.com/api/v1

The full script is in [LinkFilesToADocument.sh](LinkFilesToADocument.sh).


Set a directory you want to watch for files:

    FOLDER=/path/to/instrument-data-folder

For each file in the script, we can upload this to RSpace, and get its ID, then attach to a document.

```
## iterate over files in the folder (not subfolders)
for f in $(find $FOLDER -type f -maxdepth 1 ) ; do
  echo "ploading $f"
  uploaded_file_id=$(curl -X POST "$RSPACE_URL/files" -H "accept: application/json" -H "apiKey: $RSPACE_API_KEY" -H "Content-Type: multipart/form-data" -F "file=@$f"  | jq '.id')
  append_file_link
  ## uncomment the line below to delete the file after uploading it.
  #rm $f
done
```

To link the file to a document, you'll need the document ID and the form ID.

```
    DOC_ID=12345
    FORM_ID=67890
```

First of all, get the content of the document - it might have existing content we want to modify.  We parse out the field content and its ID.
We want to attach files to the second field (i.e at index 1).

```
  get content of existing field
  doc=$(curl  "$RSPACE_URL/documents/$DOC_ID" -H "accept: application/json" -H "apiKey: $RSPACE_API_KEY")
  doc_field_id=$(echo $doc | jq '.fields[1].id')
  field_content=$(echo $doc | jq --raw-output '.fields[1].content')
 ```

Now we append file link to the end of the field to generate new content.
We use `jq` to modify a JSON template with the correct field id, form id and new content.

Note the `<fileId=XXXX>` notation - RSpace will turn this into a correctly formatted link based on the type of the file.

```
  new_field_content="${field_content}<fileId=${uploaded_file_id}>"
  echo $new_field_content

  ## replace content with new content
  post_body_template='{"form":{"id":$form_id }, "fields":[{"id":$field_id, "content":$content}]}'
  post_body=$(jq -n --arg form_id "$FORM_ID" --arg content "$new_field_content" --arg field_id "$doc_field_id"  "$post_body_template")
```

Finally we PUT the new content to the document. `$postBody` contains the JSON string with the new content.

```
  curl  -X PUT -H "content-type: application/json" -H "apiKey: $RSPACE_API_KEY" -d "$post_body" "RSPACE_URL/documents/$DOC_ID"
```

# Improvements

Several improvements are possible, e.g.

* Execution of this script could be scheduled, e.g. using `cron`
* All the files could be linked at once - this would save bandwidth and time if uploading many files.
* Only new files not previously uplaoded could be sent to RSpace, rather than all files/ 
