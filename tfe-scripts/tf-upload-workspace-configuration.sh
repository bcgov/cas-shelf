#!/bin/bash

# 1. Define variables
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <path_to_content_directory> <organization>/<workspace>"
  exit 1
fi

PWD="$(dirname "$0")"
source "$PWD/helpers/tf-api.sh"

CONTENT_DIRECTORY="$1"
ORG_NAME="$(cut -d'/' -f1 <<<"$2")"
WORKSPACE_NAME="$(cut -d'/' -f2 <<<"$2")"

# 2. Create or find the workspace and look up the ID
WORKSPACE_ID="$("$PWD"/tf-create-workspace-if-not-exist.sh "$ORG_NAME" "$WORKSPACE_NAME")"

# 3. Create the file for upload
UPLOAD_FILE_NAME="./content-$(date +%s).tar.gz"
tar -zcvf "$UPLOAD_FILE_NAME" -C "$CONTENT_DIRECTORY" .

# 4. Create a new configuration version
DATA='{"data":{"type":"configuration-versions","attributes":{"auto-queue-runs":false}}}'

UPLOAD_URL="$(create_configuration "$WORKSPACE_ID" "$DATA" | jq -r '.data.attributes."upload-url"')"

# 5. Upload the configuration content file
upload_configuration "$UPLOAD_URL" "$UPLOAD_FILE_NAME"

# 6. Delete temporary files
rm "$UPLOAD_FILE_NAME"
