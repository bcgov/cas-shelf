#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <organization> <workspace_name>"
  exit 0
fi

source "$(dirname "$0")/helpers/tf-api.sh"

ORGANIZATION_NAME="$1"
WORKSPACE_NAME="$2"

WORKSPACE_ID="$(get_workspace_by_name "$ORGANIZATION_NAME" "$WORKSPACE_NAME" | base64 -d | jq -r '.data.id')"

if [ "$WORKSPACE_ID" != null ]; then
  echo "$WORKSPACE_ID"
  exit 0
fi

# shellcheck disable=SC2016
DATA="$(jq -n --arg workspace_name "$WORKSPACE_NAME" '{"data":{"attributes":{"name":$workspace_name,"auto-apply":true},"type":"workspaces"}}')"

WORKSPACE_ID="$(create_workspace "$ORGANIZATION_NAME" "$DATA" | base64 -d | jq -r '.data.id')"

echo "$WORKSPACE_ID"
