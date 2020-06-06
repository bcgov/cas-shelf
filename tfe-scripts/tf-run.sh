#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <workspace_id> [--delete]"
  echo "Usage: $0 <organization> <workspace_name> [--delete]"
  exit 1
fi

pwd="$(dirname "$0")"
source "$pwd/helpers/tf-api.sh"
source "$pwd/helpers/tf-common.sh"

is_destroy="false"

if [ -z "$2" ]; then
  workspace_id=$1
  if [ "$2" == "--delete" ]; then is_destroy="true"; fi
else
  organization_name="$1"
  workspace_name="$2"
  workspace_response="$(get_workspace_by_name "$organization_name" "$workspace_name")"

  if is_error_response "$workspace_response"; then exit 1; fi
  workspace_id="$(echo "$workspace_response" | jq -r '.data.id')"
  if [ "$3" == "--delete" ]; then is_destroy="true"; fi
fi

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
# shellcheck disable=SC2016
run_payload="$(jq -n --arg workspace_id "$workspace_id" --arg is_destroy "$is_destroy" '{"data":{"type":"runs","attributes":{"is-destroy":$is_destroy},"relationships":{"workspace":{"data":{"type":"workspaces","id":$workspace_id}}}}}')"

run_id="$(create_run "$run_payload" | jq -r '.data.id')"

echo "$run_id"
