#!/bin/bash

# 1. Define variables
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <path_to_content_directory> <organization>/<workspace>"
  exit 0
fi

CONTENT_DIRECTORY="$1"
ORG_NAME="$(cut -d'/' -f1 <<<"$2")"
WORKSPACE_NAME="$(cut -d'/' -f2 <<<"$2")"

# 2. Create or find the workspace and look up the ID
WORKSPACE_ID=($(./tfe-scripts/tf-create-workspace-if-not-exist.sh "$ORG_NAME" "$WORKSPACE_NAME"))

# 3. Create the file for upload
UPLOAD_FILE_NAME="./content-$(date +%s).tar.gz"
tar -zcvf "$UPLOAD_FILE_NAME" -C "$CONTENT_DIRECTORY" .

# 4. Create a new configuration version
echo '{"data":{"type":"configuration-versions","attributes":{"auto-queue-runs":false}}}' >./create_config_version.json

UPLOAD_URL=($(curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @create_config_version.json \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/configuration-versions |
  jq -r '.data.attributes."upload-url"'))

# 5. Upload the configuration content file
curl \
  --header "Content-Type: application/octet-stream" \
  --request PUT \
  --data-binary @"$UPLOAD_FILE_NAME" \
  $UPLOAD_URL

# 6. Delete temporary files
rm "$UPLOAD_FILE_NAME"
rm ./create_config_version.json
