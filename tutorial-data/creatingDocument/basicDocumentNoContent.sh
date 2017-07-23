# The simplest document creation - An empty, untagged, untitled Basic Document of a single text field:
# Note empty body content '-d {}'
curl -X POST -H "content-type: application/json" -H "apiKey:<APIKEY>" -d {} \
  "<RSPAC_URL>/api/v1/documents"
 

