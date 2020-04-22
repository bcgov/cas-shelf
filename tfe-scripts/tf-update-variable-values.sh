#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <path_to_variables_file> <workspace_id>"
  echo "Usage: $0 <path_to_variables_file> <organization> <workspace_name>"
  exit 0
fi

VARIABLE_FILE=$1

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

while IFS= read -r line; do
  VAR_KEY="$(cut -d'=' -f1 <<<"$line")"
  VAR_VAL="$(cut -d'=' -f2- <<<"$line")"

  if [ ! -z "$VAR_KEY" ] && [ ! -z "$VAR_VAL" ]; then
    ./tfe-scripts/tf-update-variable-value.sh "$WORKSPACE_ID" "$VAR_KEY" "$VAR_VAL"
  fi
done < <(grep . "${VARIABLE_FILE}")

./tfe-scripts/tf-update-variable-value.sh "$WORKSPACE_ID" terraform_cloud_workspace_id "$WORKSPACE_ID"
./tfe-scripts/tf-update-variable-value.sh "$WORKSPACE_ID" terraform_cloud_token "$TFC_TOKEN"
