#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <workspace_id> <variable_name> <item>"
  exit 0
fi

source "$(dirname "$0")/helpers/tf-api.sh"

WORKSPACE_ID="$1"
VARIABLE_NAME="$2"
ITEM="$3"

LIST_RESULT="$(list_vars "$WORKSPACE_ID")"

i=0
for key in $(echo "$LIST_RESULT" | base64 -d | jq -r '.data[] .attributes.key'); do
  if [ "$VARIABLE_NAME" == "$key" ]; then
    break
  fi
  ((i = i + 1))
done

VAR_ID="$(echo "$LIST_RESULT" | base64 -d | jq -r ".data[$i] .id")"
VALUE="$(echo "$LIST_RESULT" | base64 -d | jq -r ".data[$i] .attributes.value")"
NEW_VALUE="$(echo "$VALUE" | jq ". + [\"$ITEM\"] | unique")"

# shellcheck disable=SC2016
DATA="$(jq -n --arg new_value "$NEW_VALUE" '{"data":{"attributes":{"value":$new_value}}}')"

VAR_ID="$(update_var "$WORKSPACE_ID" "$VAR_ID" "$DATA" | base64 -d | jq -r '.data.id')"

echo "$VAR_ID"
