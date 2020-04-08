#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <organization> <workspace>"
  exit 0
fi

ORGANIZATION_NAME="$1"
WORKSPACE_NAME="$2"

curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request DELETE \
  https://app.terraform.io/api/v2/organizations/$ORGANIZATION_NAME/workspaces/$WORKSPACE_NAME
