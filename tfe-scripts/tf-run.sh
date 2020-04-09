#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <workspace_id> [--delete]"
  echo "Usage: $0 <organization> <workspace_name> [--delete]"
  exit 0
fi

IS_DESTROY="false"

if [ -z "$2" ]; then
  WORKSPACE_ID=$1
  if [ "$2" == "--delete" ]; then IS_DESTROY="true"; fi
else
  ORGANIZATION_NAME="$1"
  WORKSPACE_NAME="$2"
  WORKSPACE_ID=($(curl \
    --header "Authorization: Bearer $TFC_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    https://app.terraform.io/api/v2/organizations/$ORGANIZATION_NAME/workspaces/$WORKSPACE_NAME |
    jq -r '.data.id'))
  if [ "$3" == "--delete" ]; then IS_DESTROY="true"; fi
fi

echo "{
  \"data\": {
    \"type\": \"runs\",
    \"attributes\": {
      \"is-destroy\":$IS_DESTROY
    },
    \"relationships\": {
      \"workspace\": {
        \"data\": {
          \"type\": \"workspaces\",
          \"id\": \"$WORKSPACE_ID\"
        }
      }
    }
  }
}" >./run_payload.json

RUN_ID=($(curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @run_payload.json \
  https://app.terraform.io/api/v2/runs |
  jq -r '.data.id'))

echo $RUN_ID

rm ./run_payload.json
