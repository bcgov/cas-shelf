#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <organization> <workspace_name>"
  exit 1
fi

source "$(dirname "$0")/helpers/tf-api.sh"

organization_name="$1"
workspace_name="$2"

workspace_id="$(get_workspace_by_name "$organization_name" "$workspace_name" | jq -r '.data.id')"

if [ "$workspace_id" != null ]; then
  echo "$workspace_id"
  exit 0
fi

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
# shellcheck disable=SC2016
data="$(jq -n --arg workspace_name "$workspace_name" '{"data":{"attributes":{"name":$workspace_name,"auto-apply":true},"type":"workspaces"}}')"

workspace_id="$(create_workspace "$organization_name" "$data" | jq -r '.data.id')"

echo "$workspace_id"
