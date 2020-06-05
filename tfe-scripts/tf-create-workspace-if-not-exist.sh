#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <organization> <workspace_name>"
  exit 1
fi

pwd="$(dirname "$0")"
source "$pwd/helpers/tf-api.sh"
source "$pwd/helpers/tf-common.sh"

organization_name="$1"
workspace_name="$2"

workspace_response="$(get_workspace_by_name "$organization_name" "$workspace_name")"

if is_unauthorized "$workspace_response"; then exit 1; fi

if ! has_not_found "$workspace_response"; then
  workspace_id="$(echo "$workspace_response" | jq -r '.data.id')"
  echo "$workspace_id"
  exit 0
fi

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
# shellcheck disable=SC2016
data="$(jq -n --arg workspace_name "$workspace_name" '{"data":{"attributes":{"name":$workspace_name,"auto-apply":true},"type":"workspaces"}}')"

workspace_response="$(create_workspace "$organization_name" "$data")"
if is_error_response "$workspace_response"; then exit 1; fi
workspace_id="$(echo "$workspace_response" | jq -r '.data.id')"

echo "$workspace_id"
