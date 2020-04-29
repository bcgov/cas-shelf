#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <workspace_id> [--delete]"
  echo "Usage: $0 <organization> <workspace_name> [--delete]"
  exit 0
fi

source "$(dirname "$0")/helpers/tf-api.sh"

IS_DESTROY="false"

if [ -z "$2" ]; then
  WORKSPACE_ID=$1
  if [ "$2" == "--delete" ]; then IS_DESTROY="true"; fi
else
  ORGANIZATION_NAME="$1"
  WORKSPACE_NAME="$2"
  WORKSPACE_ID="$(get_workspace_by_name "$ORGANIZATION_NAME" "$WORKSPACE_NAME" | jq -r '.data.id')"
  if [ "$3" == "--delete" ]; then IS_DESTROY="true"; fi
fi

# shellcheck disable=SC2016
RUN_PAYLOAD="$(jq -n --arg workspace_id "$WORKSPACE_ID" --arg is_destroy "$IS_DESTROY" '{"data":{"type":"runs","attributes":{"is-destroy":$is_destroy},"relationships":{"workspace":{"data":{"type":"workspaces","id":$workspace_id}}}}}')"

RUN_ID="$(create_run "$RUN_PAYLOAD" | jq -r '.data.id')"

echo "$RUN_ID"
