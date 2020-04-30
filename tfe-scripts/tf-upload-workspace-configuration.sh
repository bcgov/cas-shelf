#!/bin/bash

# 1. Define variables
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <path_to_content_directory> <organization>/<workspace>"
  exit 1
fi

pwd="$(dirname "$0")"
source "$pwd/helpers/tf-api.sh"

content_directory="$1"
org_name="$(cut -d'/' -f1 <<<"$2")"
workspace_name="$(cut -d'/' -f2 <<<"$2")"

# 2. Create or find the workspace and look up the ID
workspace_id="$("$pwd"/tf-create-workspace-if-not-exist.sh "$org_name" "$workspace_name")"

# 3. Create the file for upload
upload_file_name="./content-$(date +%s).tar.gz"
tar -zcvf "$upload_file_name" -c "$content_directory" .

# 4. Create a new configuration version
data='{"data":{"type":"configuration-versions","attributes":{"auto-queue-runs":false}}}'

upload_url="$(create_configuration "$workspace_id" "$data" | jq -r '.data.attributes."upload-url"')"

# 5. Upload the configuration content file
upload_configuration "$upload_url" "$upload_file_name"

# 6. Delete temporary files
rm "$upload_file_name"
