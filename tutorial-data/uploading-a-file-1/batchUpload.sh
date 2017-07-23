for file in $*; do
curl -v  -X POST -H "accept: application/json" -H "apiKey: <APIKEY>" -H "content-type: multipart/form-data" -F "file=@${file}"  "<RSPACE_URL>/api/v1/files"
done;