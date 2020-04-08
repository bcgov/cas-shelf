#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <organization> <workspace_name>"
  exit 0
fi

ORGANIZATION_NAME="$1"
WORKSPACE_NAME="$2"

WORKSPACE_ID=($(curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/organizations/$ORGANIZATION_NAME/workspaces/$WORKSPACE_NAME |
  jq -r '.data.id'))

if [ "$WORKSPACE_ID" != null ]; then
  echo $WORKSPACE_ID
  exit 0
fi

echo "{\"data\":{\"attributes\":{\"name\":\"$WORKSPACE_NAME\"},\"type\":\"workspaces\"}}" >./create_workspace.json

WORKSPACE_ID=($(curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @create_workspace.json \
  https://app.terraform.io/api/v2/organizations/$ORGANIZATION_NAME/workspaces |
  jq -r '.data.id'))

echo $WORKSPACE_ID

rm ./create_workspace.json
