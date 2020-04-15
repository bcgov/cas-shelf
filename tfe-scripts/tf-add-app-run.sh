#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <item>"
  exit 0
fi

VARIABLE_NAME=namespace_apps
APP="$1"

LIST_RESULT=($(curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/workspaces/$TFC_WORKSPACE_ID/vars" | jq -r '. | @base64'))

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
  if [ "$APP" != "$item" ]; then
    NEW_VALUE=$NEW_VALUE\\\"$item\\\"","
  fi
done
NEW_VALUE=$NEW_VALUE\\\"$APP\\\""]"

VAR_ID=($(curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request PATCH \
  --data "{\"data\":{\"attributes\":{\"value\":\"$NEW_VALUE\"}}}" \
  https://app.terraform.io/api/v2/workspaces/$TFC_WORKSPACE_ID/vars/$VAR_ID |
  jq -r '.data.id'))

echo "var id"
echo $VAR_ID

RUN_PAYLOAD="{\"data\":{\"type\":\"runs\",\"relationships\":{\"workspace\":{\"data\":{\"type\":\"workspaces\",\"id\":\"$TFC_WORKSPACE_ID\"}}}}}"

RUN_ID=($(curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data $RUN_PAYLOAD \
  https://app.terraform.io/api/v2/runs |
  jq -r '.data.id'))

get_status() {
  RESULT=($(curl \
    --header "Authorization: Bearer $TFC_TOKEN" \
    "https://app.terraform.io/api/v2/runs/$RUN_ID" | jq -r '. | @base64'))

  STATUS=$(echo "${RESULT}" | base64 --decode | jq -r '.data.attributes.status')

  if [ "$STATUS" == "errored" ]; then return 1; fi
  if [ "$STATUS" == "applied" ]; then return 1; fi
  if [ "$STATUS" == "planned_and_finished" ]; then return 1; fi
}

while get_status; do sleep 5; done

echo $STATUS
