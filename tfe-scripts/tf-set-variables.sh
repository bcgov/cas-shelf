#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <path_to_variables_directory> <workspace_id>"
  echo "Usage: $0 <path_to_variables_directory> <organization> <workspace_name>"
  exit 0
fi

PWD="$(dirname "$0")"
source "$PWD/helpers/tf-api.sh"

VARIABLE_DIRECTORY="$1"

if [ -z "$3" ]; then
  WORKSPACE_ID="$2"
else
  ORGANIZATION_NAME="$2"
  WORKSPACE_NAME="$3"
  WORKSPACE_ID="$(get_workspace_by_name "$ORGANIZATION_NAME" "$WORKSPACE_NAME" | jq -r '.data.id')"
fi

for f in "$VARIABLE_DIRECTORY"*.json; do
  "$PWD"/tf-create-or-update-variable.sh "$f" "$WORKSPACE_ID"
done
