# Aim

You have some text files and you'd like to create RSpace documents with the content added in.
These files could be plain .txt files or Wiki or Markdown syntax files, for example.

# Background

Uploading files to RSpace is straightforward using the `files/` API. These files
remain as attachments, though, which might not always be what you want if you want
the content to be easily edited in RSpace.

This recipe shows how to upload plain text files and convert them to simple RSpace documents. The challenge here
is how to escape characters in the text file that would break the JSON text being sent to the server.

Note that this recipe won't work for binary files such as MSOffice files.

It has been developed on a standard Bash shell and tested on MacOS and Ubuntu Linux.

# Software required

You'll need `curl` and `jq`; both are readily available from package managers.

# Recipe
    ## step 1
    for file in myfiles*.txt; do
      echo "uploading $file  to $RSPACE_URL ..."
      
      ## step 2
      filename=$(basename $file)
      
      ## step 3
      value=`cat $file`
      
      ## step 4
      jq -n --arg fieldContent "$value" --arg f "$filename" --arg targetFolder "$targetFolderId"\
      '{name: $f, tags: "API,example", parentFolderId: $targetFolder, fields: [ {content: $fieldContent}]}'\
      > content-tmp.txt
      
      ## step 5
      sed -e 's:\\n:<br/>:g' < content-tmp.txt > content-with-html-newlines.txt
      
      ## step 6
      curl -X POST -H "content-type: application/json" -H "apiKey:$API_KEY"\ 
       -d @content-with-html-newlines.txt "$RSPACE_URL/documents"
      
      ## step 7
      rm content-tmp.txt
      rm content-with-html-newlines.txt
    done
    
# Explanation

Most of the work here is preparing the content to be posted to the `/documents POST` endpoint.

This script:

1. Finds all the text files in the current folder.
2. Extracts the file name from the path.
3. Extracts the file content into a variable, `$value`.
4. The `jq` tool  then escapes the content and sets in values into a JSON template. This steps performs the key process of converting shell variables into text in a JSON string, which is then written to a file.
5. The `sed` command is optional here. If your text file has newlines, these will be escaped by the jq tool, and the net result is that the text content will appear in one continuous line in RSpace - probably not what you want. This step will replace the newlines with '<br/>' tags. Since content in RSpace is rendered as HTML, this will ensure newlines render correctly. If your content is already HTML, then this step won't be needed.
6. Now we can finally post the content to RSpace! Note the use of the `-d @content-with-html-newlines.txt` in the curl command, which takes the JSON from a file.
7. Here we tidy up and remove temporary files.

# Conclusion

You now have a native RSpace document that can easily be edited, printed, shared or exported, just as if you had created it manually in the text editor.

A working script in [Create-RSpaceDocument-from-a-text-file.sh](Create-RSpaceDocument-from-a-text-file.sh).
