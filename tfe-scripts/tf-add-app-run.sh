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

i=0
for key in $(echo "$LIST_RESULT" | base64 -d | jq -r '.data[] .attributes.key'); do
  if [ "$VARIABLE_NAME" == "$key" ]; then
    break
  fi
  ((i = i + 1))
done

VAR_ID="$(echo "$LIST_RESULT" | base64 -d | jq -r ".data[$i] .id")"

if [ "$VAR_ID" == null ]; then
  echo "variable 'namespace_apps' not found"
  exit 0
fi

VALUE="$(echo "$LIST_RESULT" | base64 -d | jq -r ".data[$i] .attributes.value")"
NEW_VALUE="$(echo "$VALUE" | jq ". + [\"$APP\"] | unique")"

# shellcheck disable=SC2016
DATA="$(jq -n --arg new_value "$NEW_VALUE" '{"data":{"attributes":{"value":$new_value}}}')"

VAR_ID="$(update_var "$TFC_WORKSPACE_ID" "$VAR_ID" "$DATA" | base64 -d | jq -r '.data.id')"

echo "$VAR_ID"

# shellcheck disable=SC2016
RUN_PAYLOAD="$(jq -n --arg workspace_id "$TFC_WORKSPACE_ID" '{"data":{"type":"runs","relationships":{"workspace":{"data":{"type":"workspaces","id":$workspace_id}}}}}')"

RUN_ID="$(create_run "$RUN_PAYLOAD" | base64 -d | jq -r '.data.id')"

get_status() {
  STATUS="$(get_run "$RUN_ID" | base64 -d | jq -r '.data.attributes.status')"

  if [ "$STATUS" == "errored" ]; then return 1; fi
  if [ "$STATUS" == "applied" ]; then return 1; fi
  if [ "$STATUS" == "planned_and_finished" ]; then return 1; fi
}

while get_status; do sleep 5; done

echo "$STATUS"
