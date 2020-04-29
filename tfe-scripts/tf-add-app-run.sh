#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <namespace> <app>"
  exit 1
fi

source "$(dirname "$0")/helpers/tf-api.sh"

NAMESPACE="$1"
APP="$2"
NAMESPACE_APP="${NAMESPACE},${APP}"

NAMESPACE_APPS_KEY="namespace_apps"
NAMESPACES_KEY="kubernetes_namespaces"

LIST_RESULT="$(list_vars "$TFC_WORKSPACE_ID")"

if [ "$LIST_RESULT" == null ]; then
  echo "invalid workspace"
  exit 1
fi

NAPESPACE_APPS_DATA="$(echo "$LIST_RESULT" | jq -r ".data[] | select(.attributes.key == \"$NAMESPACE_APPS_KEY\") | .")"
NAMESPACE_APPS_ID="$(echo "$NAPESPACE_APPS_DATA" | jq -r ".id")"

NAMESPACES_DATA="$(echo "$LIST_RESULT" | jq -r ".data[] | select(.attributes.key == \"$NAMESPACES_KEY\") | .")"
NAMESPACES_ID="$(echo "$NAMESPACES_DATA" | jq -r ".id")"

if [ "$NAMESPACE_APPS_ID" == null ]; then
  echo "variable $NAMESPACE_APPS_KEY not found"
  exit 1
fi

if [ "$NAMESPACES_ID" == null ]; then
  echo "variable $NAMESPACES_KEY not found"
  exit 1
fi

# update `namespace_apps`
NAPESPACE_APPS_VALUE="$(echo "$NAPESPACE_APPS_DATA" | jq -r ".attributes.value")"
NAPESPACE_APPS_NEW_VALUE="$(echo "$NAPESPACE_APPS_VALUE" | jq ". + [\"$NAMESPACE_APP\"] | unique")"

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
# shellcheck disable=SC2016
NAPESPACE_APPS_DATA_TO_UPDATE="$(jq -n --arg new_value "$NAPESPACE_APPS_NEW_VALUE" '{"data":{"attributes":{"value":$new_value}}}')"

NAMESPACE_APPS_ID="$(update_var "$TFC_WORKSPACE_ID" "$NAMESPACE_APPS_ID" "$NAPESPACE_APPS_DATA_TO_UPDATE" | jq -r '.data.id')"

echo "$NAMESPACE_APPS_ID"

# update `kubernetes_namespaces`
NAMESPACES_VALUE="$(echo "$NAMESPACES_DATA" | jq -r ".attributes.value")"
NAMESPACES_NEW_VALUE="$(echo "$NAMESPACES_VALUE" | jq ". + [\"$NAMESPACE\"] | unique")"

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
# shellcheck disable=SC2016
NAPESPACES_DATA_TO_UPDATE="$(jq -n --arg new_value "$NAMESPACES_NEW_VALUE" '{"data":{"attributes":{"value":$new_value}}}')"

NAMESPACES_ID="$(update_var "$TFC_WORKSPACE_ID" "$NAMESPACES_ID" "$NAPESPACES_DATA_TO_UPDATE" | jq -r '.data.id')"

echo "$NAMESPACES_ID"

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
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
