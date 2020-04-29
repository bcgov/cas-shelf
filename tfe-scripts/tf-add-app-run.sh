#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <namespace> <app>"
  exit 0
fi

source "$(dirname "$0")/helpers/tf-api.sh"

NAMESPACE="$1"
APP="$2"
NAMESPACE_APP="${NAMESPACE},${APP}"

VAR1="namespace_apps"
VAR2="kubernetes_namespaces"

LIST_RESULT="$(list_vars "$TFC_WORKSPACE_ID")"

if [ "$LIST_RESULT" == null ]; then
  echo "invalid workspace"
  exit 0
fi

VAR_DATA1="$(echo "$LIST_RESULT" | jq -r ".data[] | select(.attributes.key == \"$VAR1\") | .")"
VAR_ID1="$(echo "$VAR_DATA1" | jq -r ".id")"

VAR_DATA2="$(echo "$LIST_RESULT" | jq -r ".data[] | select(.attributes.key == \"$VAR2\") | .")"
VAR_ID2="$(echo "$VAR_DATA2" | jq -r ".id")"

if [ "$VAR_ID1" == null ]; then
  echo "variable $VAR1 not found"
  exit 0
fi

if [ "$VAR_ID2" == null ]; then
  echo "variable $VAR2 not found"
  exit 0
fi

# update `namespace_apps`
VALUE1="$(echo "$VAR_DATA1" | jq -r ".attributes.value")"
NEW_VALUE1="$(echo "$VALUE1" | jq ". + [\"$NAMESPACE_APP\"] | unique")"

# shellcheck disable=SC2016
DATA1="$(jq -n --arg new_value "$NEW_VALUE1" '{"data":{"attributes":{"value":$new_value}}}')"

VAR_ID1="$(update_var "$TFC_WORKSPACE_ID" "$VAR_ID1" "$DATA1" | jq -r '.data.id')"

echo "$VAR_ID1"

# update `kubernetes_namespaces`
VALUE2="$(echo "$VAR_DATA2" | jq -r ".attributes.value")"
NEW_VALUE2="$(echo "$VALUE2" | jq ". + [\"$NAMESPACE\"] | unique")"

# shellcheck disable=SC2016
DATA2="$(jq -n --arg new_value "$NEW_VALUE2" '{"data":{"attributes":{"value":$new_value}}}')"

VAR_ID2="$(update_var "$TFC_WORKSPACE_ID" "$VAR_ID2" "$DATA2" | jq -r '.data.id')"

echo "$VAR_ID2"

# shellcheck disable=SC2016
RUN_PAYLOAD="$(jq -n --arg workspace_id "$TFC_WORKSPACE_ID" '{"data":{"type":"runs","relationships":{"workspace":{"data":{"type":"workspaces","id":$workspace_id}}}}}')"

RUN_ID="$(create_run "$RUN_PAYLOAD" | jq -r '.data.id')"

get_status() {
  STATUS="$(get_run "$RUN_ID" | jq -r '.data.attributes.status')"

  if [ "$STATUS" == "errored" ]; then return 1; fi
  if [ "$STATUS" == "discarded" ]; then return 1; fi
  if [ "$STATUS" == "applied" ]; then return 1; fi
  if [ "$STATUS" == "planned_and_finished" ]; then return 1; fi
}

while get_status; do sleep 5; done

echo "$STATUS"
