#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <workspace_id> <variable_name> <item>"
  exit 1
fi

source "$(dirname "$0")/helpers/tf-api.sh"

WORKSPACE_ID="$1"
VARIABLE_NAME="$2"
ITEM="$3"

LIST_RESULT="$(list_vars "$WORKSPACE_ID")"
VAR_DATA="$(echo "$LIST_RESULT" | jq -r ".data[] | select(.attributes.key == \"$VARIABLE_NAME\") | .")"
VAR_ID="$(echo "$VAR_DATA" | jq -r ".id")"
VALUE="$(echo "$VAR_DATA" | jq -r ".attributes.value")"
NEW_VALUE="$(echo "$VALUE" | jq ". + [\"$ITEM\"] | unique")"

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
# shellcheck disable=SC2016
DATA="$(jq -n --arg new_value "$NEW_VALUE" '{"data":{"attributes":{"value":$new_value}}}')"

VAR_ID="$(update_var "$WORKSPACE_ID" "$VAR_ID" "$DATA" | jq -r '.data.id')"

echo "$VAR_ID"
