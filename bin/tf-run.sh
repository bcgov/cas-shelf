#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <workspace_id>"
  exit 0
fi

WORKSPACE_ID=$1

echo "{
  \"data\": {
    \"type\": \"runs\",
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

curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @run_payload.json \
  https://app.terraform.io/api/v2/runs
