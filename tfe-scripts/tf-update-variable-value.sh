#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <workspace_id> <var_key> <var_value>"
  exit 0
fi

WORKSPACE_ID="$1"
VAR_KEY="$2"
VAR_VALUE="$3"

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

echo "{\"data\":{\"attributes\":{\"value\":\"$VAR_VALUE\"}}}" >./variable.json

VAR_ID=($(curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request PATCH \
  --data @variable.json \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars/$VAR_ID |
  jq -r '.data.id'))

echo $VAR_ID

rm ./variable.json
