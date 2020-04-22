#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <path_to_payload_file> <workspace_id>"
  exit 0
fi

PAYLOAD_FILE="$1"
WORKSPACE_ID="$2"

VAR_KEY=$(cat $PAYLOAD_FILE | jq -r '.data.attributes.key')
if [ "$VAR_KEY" == null ]; then
  echo "variable key not found"
  exit 0
fi

VAR_ID=($(curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @$PAYLOAD_FILE \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars |
  jq -r '.data.id'))

if [ "$VAR_ID" != null ]; then
  echo $VAR_ID
  exit 0
fi

LIST_RESULT=($(curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars" | jq -r '. | @base64'))

i=0
for key in $(echo "${LIST_RESULT}" | base64 --decode | jq -r '.data[] .attributes.key'); do
  if [ "$VAR_KEY" == "$key" ]; then
    break
  fi
  ((i = i + 1))
done

VAR_ID=$(echo "${LIST_RESULT}" | base64 --decode | jq -r ".data[$i] .id")

VAR_ID=($(curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request PATCH \
  --data @$PAYLOAD_FILE \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars/$VAR_ID |
  jq -r '.data.id'))

echo $VAR_ID
