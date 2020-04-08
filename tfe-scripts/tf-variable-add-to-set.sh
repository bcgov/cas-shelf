#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <workspace_id> <variable_name> <item>"
  exit 0
fi

WORKSPACE_ID="$1"
VARIABLE_NAME="$2"
ITEM="$3"

LIST_RESULT=($(curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars" | jq -r '. | @base64'))

i=0
for key in $(echo "${LIST_RESULT}" | base64 --decode | jq -r '.data[] .attributes.key'); do
  if [ "$VARIABLE_NAME" == "$key" ]; then
    break
  fi
  ((i = i + 1))
done

VAR_ID=$(echo "${LIST_RESULT}" | base64 --decode | jq -r ".data[$i] .id")
VALUE=$(echo "${LIST_RESULT}" | base64 --decode | jq -r ".data[$i] .attributes.value | @base64")

NEW_VALUE="["
for item in $(echo "${VALUE}" | base64 --decode | jq -r ".[]"); do
  if [ "$ITEM" != "$item" ]; then
    NEW_VALUE=$NEW_VALUE\\\"$item\\\"","
  fi
done
NEW_VALUE=$NEW_VALUE\\\"$ITEM\\\""]"

echo "{\"data\":{\"attributes\":{\"value\":\"$NEW_VALUE\"}}}" >./new-array-variable.json

VAR_ID=($(curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request PATCH \
  --data @new-array-variable.json \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars/$VAR_ID |
  jq -r '.data.id'))

echo $VAR_ID

rm ./new-array-variable.json
