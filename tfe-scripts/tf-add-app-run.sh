#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <item>"
  exit 0
fi

source "$(dirname "$0")/helpers/tf-api.sh"

VARIABLE_NAME="namespace_apps"
APP="$1"

LIST_RESULT="$(list_vars "$TFC_WORKSPACE_ID")"

if [ "$LIST_RESULT" == null ]; then
  echo "invalid workspace"
  exit 0
fi

VAR_DATA="$(echo "$LIST_RESULT" | jq -r ".data[] | select(.attributes.key == \"$VARIABLE_NAME\") | .")"
VAR_ID="$(echo "$VAR_DATA" | jq -r ".id")"

if [ "$VAR_ID" == null ]; then
  echo "variable 'namespace_apps' not found"
  exit 0
fi

VALUE="$(echo "$VAR_DATA" | jq -r ".attributes.value")"
NEW_VALUE="$(echo "$VALUE" | jq ". + [\"$APP\"] | unique")"

# shellcheck disable=SC2016
DATA="$(jq -n --arg new_value "$NEW_VALUE" '{"data":{"attributes":{"value":$new_value}}}')"

VAR_ID="$(update_var "$TFC_WORKSPACE_ID" "$VAR_ID" "$DATA" | jq -r '.data.id')"

echo "$VAR_ID"

# shellcheck disable=SC2016
RUN_PAYLOAD="$(jq -n --arg workspace_id "$TFC_WORKSPACE_ID" '{"data":{"type":"runs","relationships":{"workspace":{"data":{"type":"workspaces","id":$workspace_id}}}}}')"

RUN_ID="$(create_run "$RUN_PAYLOAD" | jq -r '.data.id')"

get_status() {
  STATUS="$(get_run "$RUN_ID" | jq -r '.data.attributes.status')"

  if [ "$STATUS" == "errored" ]; then return 1; fi
  if [ "$STATUS" == "applied" ]; then return 1; fi
  if [ "$STATUS" == "planned_and_finished" ]; then return 1; fi
}

while get_status; do sleep 5; done

echo "$STATUS"
