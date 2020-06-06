#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <path_to_variables_directory> <workspace_id>"
  echo "Usage: $0 <path_to_variables_directory> <organization> <workspace_name>"
  exit 1
fi

pwd="$(dirname "$0")"
source "$pwd/helpers/tf-api.sh"
source "$pwd/helpers/tf-common.sh"

variable_directory="$1"

if [ -z "$3" ]; then
  workspace_id="$2"
else
  organization_name="$2"
  workspace_name="$3"
  workspace_response="$(get_workspace_by_name "$organization_name" "$workspace_name")"

  if is_error_response "$workspace_response"; then exit 1; fi
  workspace_id="$(echo "$workspace_response" | jq -r '.data.id')"
fi

for f in "$variable_directory"*.json; do
  "$pwd"/tf-create-or-update-variable.sh "$f" "$workspace_id"
done
