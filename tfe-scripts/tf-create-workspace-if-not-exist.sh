#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <organization> <workspace_name>"
  exit 1
fi

source "$(dirname "$0")/helpers/tf-api.sh"

ORGANIZATION_NAME="$1"
WORKSPACE_NAME="$2"

WORKSPACE_ID="$(get_workspace_by_name "$ORGANIZATION_NAME" "$WORKSPACE_NAME" | jq -r '.data.id')"

if [ "$WORKSPACE_ID" != null ]; then
  echo "$WORKSPACE_ID"
  exit 0
fi

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
# shellcheck disable=SC2016
DATA="$(jq -n --arg workspace_name "$WORKSPACE_NAME" '{"data":{"attributes":{"name":$workspace_name,"auto-apply":true},"type":"workspaces"}}')"

WORKSPACE_ID="$(create_workspace "$ORGANIZATION_NAME" "$DATA" | jq -r '.data.id')"

echo "$WORKSPACE_ID"
