#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <path_to_variables_directory> <workspace_id>"
  echo "Usage: $0 <path_to_variables_directory> <organization> <workspace_name>"
  exit 0
fi

VARIABLE_DIRECTORY=$1

if [ -z "$3" ]; then
  WORKSPACE_ID=$2
else
  ORGANIZATION_NAME="$2"
  WORKSPACE_NAME="$3"
  WORKSPACE_ID=($(curl \
    --header "Authorization: Bearer $TFC_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    https://app.terraform.io/api/v2/organizations/$ORGANIZATION_NAME/workspaces/$WORKSPACE_NAME |
    jq -r '.data.id'))

fi

for f in "$VARIABLE_DIRECTORY"*.json; do
  ./tfe-scripts/tf-create-or-update-variable.sh "$f" "$WORKSPACE_ID"
done
