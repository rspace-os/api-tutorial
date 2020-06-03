# Sharing of notebooks and documents

From RSpace 1.56 (API version 1.5) you can programmatically share notebooks and documents.

## Background

### What can be shared?

* One or more documents or notebooks can be shared.
* Only items belonging to the authenticated user can be shared. Just like in the web application, users can't share other peoples' work.

### Who can content be shared with?

* Items can be shared with one or more groups that the authenticated user belongs to.
* Items can be shared with one or more individual users in groups that the authenticated user belongs to.

## Sharing

### Before sharing

Before sending a SHARE operation, you must determine:

* The IDs of the items you want to share. You can get these IDs from the /documents GET method, either listing or searching.
* The IDs of the users/groups you want to share with. You can get these from the /groups GET endpoint, e.g.

```bash
curl -X GET "<RSPACE_URL>/api/v1/groups" \
-H "accept: application/json" -H "apiKey: <APIKEY>"
```

which will return a listing of group information. An example listing is in [groupsListing.json](tutorial-data/sharingContent/groupsListing.json)

As well as the IDs of users and groups, the `sharedFolderId` property is also useful if you want to create new shared folders to
share the content into.

Here's an example where we use the popular [jq](https://stedolan.github.io/jq/tutorial/) tool to parse out the information we want that is relevant to sharing.

```bash
curl -X GET "<RSPACE_URL>/api/v1/groups" \
   -H "accept: application/json" -H "apiKey: <APIKEY>" \
| jq '[.[] | {groupId: .id, folderId: .sharedFolderId}]'
```

### Submitting a share request

Once we have identified what we want to share, and who with, we can create the body of the request. An example is in [sharePost.json](tutorial-data/sharingContent/sharePost.json), which shows how to share 2 items with 2 groups and a user, with varying permissions.

At least one user or group must be specified, and at least one item to share. If no folder ID is set, and no permission, then the default is that the item will be shared with `READ` permission into the top-level shared folder of the group.

Here is an example of the minimal request body required to share 1 item with a group:

```json
{
  "itemsToShare": [
     1234
  ],
  "groups": [
    {
      "id": 12345
    }
  ],
  "users": []
}
```

It will be shared with READ permission into the top level of the group folder.

The response is a `ShareInfo` object summarising a successful share action. Here is an example of the response that
might be generated from the simple request body above:

```json
{
  "shareInfos": [
    {
      "id": 6789,
      "sharedItemId": 1234,
      "sharedTargetType": "GROUP",
      "permission": "READ"
    }
  ],
  "failedShareIds": []
}
```

Any items that could not be shared are added to the `failedShareIds` list.

### Unsharing

Unsharing is accomplished by a `DELETE` request, using the ID of the Share object to identify what should be unshared.
In the above example, the share ID is '6789', so we would use this in the path of the delete request:

```bash
curl -v  -X DELETE  -H "apiKey: <APIKEY>"\
  "<RSPACE_URL>/api/v1/share/6789"
```

will unshare document with id '1234' from group '12345'.

Successful deletion will return a 204 HTTP status code

### Listing shared items

It's possible to list shared items, giving similar information to that obtained from MyRSpace -> Shared Documents page.

This is a paginated and searchable method, e.g.

```bash
curl -X GET "<RSPACE_URL>/api/v1/share?pageSize=20&orderBy=name%20desc" \
-H "accept: application/json" -H "apiKey: <APIKEY>"
```

This will return a list of `ShareInfo` objects. Additionally as with all paginated listings, the `_links` attribute will contain
links to previous/next pages.
