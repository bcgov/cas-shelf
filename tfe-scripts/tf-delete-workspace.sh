#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <organization> <workspace>"
  exit 1
fi

pwd="$(dirname "$0")"
source "$pwd/helpers/tf-api.sh"
source "$pwd/helpers/tf-common.sh"

organization_name="$1"
workspace_name="$2"

workspace_response="$(delete_workspace_by_name "$organization_name" "$workspace_name")"

if is_error_response "$workspace_response"; then exit 1; fi
echo "workspace $organization_name/$workspace_name deleted successfully"
