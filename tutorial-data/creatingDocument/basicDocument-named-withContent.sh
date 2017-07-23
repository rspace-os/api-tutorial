# Creates document with simple content.
#  -d argument supplies JSON request body from the named file.
curl -v  -X POST -H "content-type: application/json" -H "apiKey: <APIKEY>" -d "@basicDocument-named-withContent.json" \
  "<RSPACE_URL>/api/v1/documents"