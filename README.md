# API Tutorial

## Introduction

This project provides an introduction to using the RSpace API.

### Who is this tutorial for?

This tutorial is intended for software developers, or scientists with programming skills,
to learn how to use the RSpace API to interact programmatically with the RSpace Electronic Lab Notebook.
All the examples can be run using a personal API token.

### How does this tutorial fit in with other RSpace API documentation?

* The [RSpace help documentation](https://researchspace.helpdocs.io/article/v0dxtfvj7u-rspace-api-introduction)
  describes how to get your API token from the RSpace UI.
* The [API technical reference](https://community.researchspace.com/public/apiDocs)
  describes low-level technical details of the API endpoints
  and API contracts.
* [Example code projects](https://github.com/rspace-os) provide language-specific API client example code.

### What version of RSpace is required for this tutorial?

RSpace 1.63 or newer is needed to follow all the steps.

### How do I develop client Apps for RSpace?

Ths tutorial covers use of personal access tokens. If you are a developer looking to incorporate OAuth authentication for a client app then please read [Using OAuth](oauth.md).

For development purposes we have a Dockerised version of RSpace which lets you test your client application against a real instance of RSpace. Please ask us, or view our [Docker Documentation](https://researchspace.helpdocs.io/article/aj63kmb3uh-running-rspace-on-docker)

### Can I contribute to this documentation?

Yes, please submit either pull requests, or emails to supportATresearchspaceDOTcom, with improvements or suggestions. We will happily add you to our list of [contributors](Contributing.md).

### Use-cases for the API

* Uploading files from instruments or your device into RSpace automatically.
* Creating RSpace documents and linking to files.
* Adding or editing content in an RSpace document.
* Searching and retrieving files and documents
* Creating folders and notebooks for organising content.
* Creating and publishing forms
* Sharing RSpace documents
* Importing MSWord or OpenOffice documents into RSpace
* Scheduled exports of your work.
* Creation of user accounts and groups (admins only)

### Getting started

* Follow the instructions in the [RSpace help documentation](http://www.researchspace.com/help-and-support-resources/rspace-api-introduction/)
  to get set up with an API key for your account.
* This tutorial will use `curl` commands to make API calls rather than assume a particular programming language.

Code examples are shown in the following syntax:

```bash
curl -v -H "accept: application/json" -H "apiKey:$APIKEY" "$RSPACE_URL/api/v1/files"
```

* The `-v` option to curl shows verbose information about the request to help you debug any problems.
* You generally need to supply the content type to be accepted, and your API key, as request headers.
Replace `$APIKEY` with your own key. You can export this as an environment variable. This is good practice, as it avoids putting secret information on the command line, e.g. in Bash shell:

```bash
export API_KEY=mysecretkey
```

Please note that Bash will save this into `.bash_history` file in the home directory. It is possible to disable the logging of `export` statements.

* Replace $RSPACE_URL with the base URL of your RSpace installation. E.g. if you're using RSpace Community, this would be `https://community.researchspace.com`. You can export this as an environment variable as well, e.g. in Bash shell:

```bash
export RSPACE_URL=https://community.researchspace.com
```

* Any other text in <ANGLE_BRACKETS> is a placeholder for a value specific to your account, e.g. a resource identifier.
* You can check your setup by making a simple call to the `/status` endpoint:

```bash
curl -H "apiKey:$APIKEY" "$RSPACE_URL/api/v1/status"
```

All code snippets are provided as working examples in the `tutorial-data` folders in this project.

## Creating content

### Uploading files

Being able to upload a file to RSpace automatically can save you a lot of time and effort compared to manually uploading files
using the web application. You can perform tasks such as:

* Bulk upload of files
* Scheduled upload of files, e.g. files generated by an instrument, sequence  files, image files etc

The simplest way to upload a file is as follows:

```bash
curl -v  -X POST -H "accept: application/json" -H "apiKey: $APIKEY" \
-H "content-type: multipart/form-data" -F "file=@<MY_FILE.txt>" \
"$RSPACE_URL/api/v1/files"
```

This will upload a file '<MY_FILE.txt>'  a  default folder called 'Api Inbox' in the relevant section
of the Gallery. This folder will be automatically created for you if it doesn't yet exist. JSON will be returned:

```json
{
  "id" : 728,
  "globalId" : "GL728",
  "name" : "<MY_FILE.txt>",
  "caption" : "",
  "contentType" : "text/plain",
  "created" : "2017-07-23T09:54:16.007Z",
  "size" : 2812,
  "version" : 1
  "_links" : [ {
     "link" : "$RSPACE_URL/api/v1/files/728",
     "rel" : "self"
   }, {
     "link" : "$RSPACE_URL/api/v1/files/728/file",
     "rel" : "enclosure"
  } ]
}
```

The `_links` property contains pre-generated links to resources created or referenced in API calls. In this case, the 'self'
link will return the file metadata, and the 'enclosure' link will download the file contents. These will be described later.

You can also upload a file with an optional caption, and also specify a folder to put the file in.

```bash
curl -v  -X POST -H "accept: application/json" -H "apiKey: $APIKEY" \
-H "content-type: multipart/form-data" -F "file=@<MY_FILE.txt>" -F"folderId=<FOLDER_ID>\
-F "caption=some metadata about this file" \"$RSPACE_URL/api/v1/files"
```

The caption will appear in the 'Info' section of each Gallery item, and just like a manually edited caption, will be searchable.
This is a good way to add some descriptive metadata to your file so that you can locate it easily.

Browsing folders via the API is not yet supported. However it's very easy to get a folder ID from RSpace by clicking
on the 'info' icon beside a Gallery folder.

**Note:** There are some restrictions on which folders you can upload to. For example, if uploading image files, a folder ID must
be either the Gallery Images folder, or a subfolder of the images folder. You can't upload a file directly into a workspace folder
or notebook.

If you're uploading many files of mixed type, then it's probably safer not to specify a single folder, but to let them be
placed in the relevant `API Inbox` folder where you can organise them later.

#### Uploading files from a folder

The script [batchUpload.sh](tutorial-data/uploading-a-file-1/batchUpload.sh) will upload files sequentially from a list
on the command line, e.g.

```bash
# upload a single file
./batchUpload.sh myFile.txt
# upload all png files in folder
./batchUpload.sh `ls *.png`
```

#### Replacing files

You can replace the file contents of a file by uploading a new version, using the ID obtained from an initial upload.

```bash
curl -v -X POST -H "accept: application/json" -H "apiKey: $APIKEY" \
-H "content-type: multipart/form-data" -F "file=@<MY_FILE.txt>" \
"$RSPACE_URL/api/v1/files/<FILE_ID>file"
```

This will also return a JSON response of the uploaded File, with updated `version` property. The `id` will remain the same.

### Downloading files

You can download files from RSpace to your device using the following syntax:

```bash
curl -v  -H "accept:application/octet-stream" -H "apiKey:$APIKEY" "$RSPACE_URL/api/v1/files/<FILE_ID>/file"
```

### Creating documents

You can create documents of different types, and add content to some or all of the fields.
Some of the examples use JSON request bodies - files of JSON data are in  [this project](tutorial-data/creatingDocument).

#### Creating a basic document

This is the simplest way to create a document - it will be a 'Basic Document' (a single text field) with default name 'Untitled Document' and
no content. Note that an empty request body '-d {}' is required.

```bash
curl -X POST -H "content-type: application/json" -H "apiKey:$APIKEY" -d {} "$RSPACE_URL/api/v1/documents"
```

This example is a little more useful - creating a named, tagged Basic Document with some content:

```bash
curl -X POST -H "content-type: application/json" -H "apiKey:$APIKEY" \
-d "@tutorial-data/creatingDocument/basicDocument-named-withContent.json" \
"$RSPACE_URL/api/v1/documents"
```

You can also set the parent folder that you want the document created in. This should be folder in your Workspace - not a shared folder.

```bash
curl -X POST -H "content-type: application/json" -H "apiKey:$APIKEY" \
-d "@tutorial-data/creatingDocument/basicDocument-named-withContent-withParentFolder.json" \
"$RSPACE_URL/api/v1/documents"
```

If you don't set parent folder, it will appear in the 'API Inbox' folder by default.

#### Creating links in documents to files

If you want to create links to files in a document's content, you can easily do this by adding a tag with the syntax:

```json
<fileId=1234>
```

to your document content, e.g. replacing '1234' with the id of your file. RSpace will then create links in exactly the same way
as it does in the UI. E.g.

```json
{
  "name": "My Experiment",
  "tags": "API,example",
  "fields": [
     {
       "content": "Protocol as described in <fileId=1234>, except using EDTA 3uM. "
     }
    ]
}
```

### Creating notebooks and folders

You can create notebooks and folders:

```bash
curl -X POST "$RSPACE_URL/api/v1/folders" -H "accept: application/json" -H "apiKey: $APIKEY" \
-H "content-type: application/json" \
-d "{ \"name\": \"My notebook\", \"notebook\": \"true\"}"
```

will create a new Notebook in your Home folder. If you prefer to create a folder just set the notebook parameter to 'false'. Or, just omit the parameter - the default behaviour is to create a folder.

You can also create a new folder or notebook in an existing folder using the `parentFolderId` parameter, e.g.

```bash
curl -X POST "$RSPACE_URL/api/v1/folders" -H "accept: application/json" -H "apiKey: $APIKEY" \
-H "content-type: application/json"\
-d "{ \"name\": \"My notebook\", \"parentFolderId\":\"12234\"}"
```

There are some restrictions on where you can create folders and notebooks, which are required to  maintain consistent behaviour
with the web application.

* You can't create folders or notebooks inside notebooks
* You can't create notebooks inside the Shared Folder; create them in a User folder first, then share. (Sharing is not yet supported in the API, but you can do this in the web application).

### Editing existing content in a basic document

You can alter the content of an existing document using a `PUT` request to the `/documents/{docId}` endpoint. The new
content will replace existing content. If someone else is editing the document, then the request will fail,
returning a `409 Conflict` error code.  

You just include in the request body the data that you want to change - any/all of name, tags and field content.

```bash
curl -v  -X PUT -H "content-type: application/json" -H "apiKey: $APIKEY"\
-d "@tutorial-data/editingDocument/editBasicDocument.json"  "$RSPACE_URL/api/v1/documents/<DOC_ID>"
```

### Creating and editing multi-field documents

Now we know how to  create simple documents, let's consider multi-field of 'Structured Documents' that contain
fields of different types as defined by a Form. You can add/edit content to any or all of the fields.

In this section we'll be using the standard 'Experiment' form that is already defined for you in RSpace. It contains
7 text fields: Method, Objective, Procedure, Results, Discussion, Conclusion, Comment.

You'll need to get the ID of the form from the UI, and include this ID as in the  'form' property in the request body.
When adding content, the order is important. If for example, you just want to add content to the 'Procedure' field,
which is the 3rd field, then supply a list of 7 fields, of which only the 3rd has some data, e.g.

```bash
curl -X POST -H "content-type: application/json" -H "apiKey:$APIKEY" \
-d "@tutorial-data/creatingDocument/complexDocument-named-withContent.json" "$RSPACE_URL/api/v1/documents"
```

When editing content, there are two options. Either you can send the data as a list of all fields, as for POST, including content
as necessary, or you can reference a field by its ID, and just send values for
[those specific fields](tutorial-data/editingDocument/editComplexDocument-named-withFieldIds.json).

```bash
curl -v  -X PUT -H "content-type: application/json" -H "apiKey: $APIKEY"\
-d "@tutorial-data/editingDocument/editComplexDocument-named-withFieldIds.json"\
"$RSPACE_URL/api/v1/documents/<DOC_ID>"
```

As for BasicDocuments, you can also edit name and tags in the request body as well.

## Navigating content

You can navigate the folder tree in an analogous way to using the 'Tree View' in the workspace UI. You can start at the Home folder:

```bash
curl -v -H"apiKey: $APIKEY" "$RSPACE_URL/api/v1/folders/tree"
```

or at a specific folder by specifying its ID:

```bash
curl -v -H"apiKey: $APIKEY" "$RSPACE_URL"/api/v1/folders/tree/<FOLDER_ID>"
```

Both the above requests will return a paginated list of basic information about each item in the folder:

```json
"totalHits": 7,
"pageNumber": 0,
"_links": [
  {
   "link": "https://rspac1918-foldertree-api-7.researchspace.com/api/v1/folders/tree?pageNumber=0",
   "rel": "self"
  }
  ],
"parentId": 162,
"records": [
  "id": 185,
  "globalId": "GL185",
  "name": "ethane.jpg",
  "created": "2019-09-26T08:22:53.434Z",
  "lastModified": "2019-09-26T08:22:53.434Z",
  "parentFolderId": 163,
  "type": "MEDIA",
  "_links": [
    {
      "link": "https://rspac1918-foldertree-api-7.researchspace.com/api/v1/files/185",
      "rel": "self"
    }
    .......
  ]
```

Note that in the above data:

* the `type` field is one of 'MEDIA', 'DOCUMENT', 'NOTEBOOK' or 'FOLDER'. Use this to identify the type of returned item.
* Use the `self` link to get more information about the individual item
* `parentId` is the parent of the listed folder. You can use this to navigate up the folder tree. If the listing is of the Home folder, `parentId` will not be set

Additionally you can restrict the results to one or any of 'document', 'folder' or 'notebook':

```bash
curl -v  -H"apiKey: $APIKEY" \
"$RSPACE_URL/api/v1/folders/tree?typesToInclude=folder,notebook&pageSize=20"
```

will return just folders and notebooks from the Home folder, paginated 20 at a time.

## Deleting content

You can mark documents  as deleted. This behaves in the same way as the web UI - documents are not completely removed
but are merely hidden from listings and search results. This is a simple call that takes single path variable, the ID
of the document to delete:

```bash
curl -v  -X DELETE  -H "apiKey: $APIKEY"\
"$RSPACE_URL/api/v1/documents/<DOC_ID>"
```

and in a similar way you can delete whole notebooks or folders as well:

```bash
curl -v  -X DELETE  -H "apiKey: $APIKEY"\
"$RSPACE_URL/api/v1/folders/<FOLDER_ID>"
```

In both these cases, if a notebook or document was previously shared, then they will be unshared as part of the deletion process.

## Forms

### Listing forms

You can list and search for Forms. The search mechanism replicates what is used
in the 'Manage Forms' page in the web application.

To list all Forms:

```bash
curl -X GET "$RSPACE_URL/api/v1/forms" -H "accept: application/json" -H "apiKey: $APIKEY"
```

As for documents and files, you can order and paginate:

```bash
curl -X GET "$RSPACE_URL/api/v1/forms?pageSize=10&orderBy=lastModified%20desc" \
-H "accept: application/json" -H "apiKey: $APIKEY"
```

Searching is by freeform wildcard search for all or part of the `name` or `tag` property of the form.

```bash
curl -X GET "$RSPACE_URL/api/v1/forms?query=Algal%20Sample" \
-H "accept: application/json" -H "apiKey: $APIKEY"
```

The search results contain summary information about each form, but does not contain the list of Field definitions. If you want to get this information, then get a single Form by its ID, e.g.

```bash
curl -X GET "$RSPACE_URL/api/v1/forms/<ID>" \
-H "accept: application/json" -H "apiKey: $APIKEY"
```

Please see [Form Help documentation](https://www.researchspace.com/enterprise/help-and-support-resources-enterprise/forms-enterprise/) for more details on how Forms are versioned and used in RSpace. As in the user interface, form searching retrieves the *current version* of a Form.

### Creating new forms

You can create new forms through the API. Read more about this in [forms.md](forms.md)

## Exporting content

You can programmatically export your work in HTML or XML format. This
might be useful if you want to make scheduled backups, for example. If you're an admin or PI you can export
a particular user's work if you have permission.

You can read more details in [jobs.md](jobs.md).

## Importing content

From RSpace 1.56, it is possible to import Microsoft Word or OpenOffice files as RSpace documents. This is the same functionality as the `Create->from Word` feature in the web application.

The API calls are similar to those for uploading files - you'll need a Word/Office file, and optionally a folder ID that you want to import into:

```bash
curl -X POST "$RSPACE_URL/api/v1/import/word" -H "accept: application/json" \
-H "apiKey: $APIKEY" -H "content-type: multipart/form-data" \
-F "file=@<WORD_FILE>.doc;type=application/msword"
```

If you don't specify a folder ID, the RSpace document will be created in the 'Api Inbox' folder.

From RSpace 1.58, Evernote .enex files can be imported using a similar mechanism, e.g.:

```bash
curl -X POST "$RSPACE_URL/api/v1/import/evernote" -H "accept: application/json" \
-H "apiKey: $APIKEY" -H "content-type: multipart/form-data" \
-F "file=@<EVERNOT_FILE>.enex;type=application/xml"
```

If successful, a new folder will be returned, containing the newly imported notes. An Evernote 'Note' will be converted into an RSpace plain text document.

## Sharing items with other groups and users

From RSpace 1.56, it is possible to share documents and notebooks programmatically. You can read more details in [sharing.md](sharing.md).

## Administration of user accounts

Users with a 'SYSADMIN' role can create new user accounts and lab groups. This API is in 'beta' in 1.59.3 and may be subject to change. More details in [creating_accounts.md](creating_accounts.md)
