#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <workspace_id> <var_key> <var_value>"
  exit 0
fi

source "$(dirname "$0")/helpers/tf-api.sh"

WORKSPACE_ID="$1"
VAR_KEY="$2"
VAR_VALUE="$3"

LIST_RESULT="$(list_vars "$WORKSPACE_ID")"

VAR_DATA="$(echo "$LIST_RESULT" | jq -r ".data[] | select(.attributes.key == \"$VAR_KEY\") | .")"
VAR_ID="$(echo "$VAR_DATA" | jq -r ".id")"

# shellcheck disable=SC2016
DATA="$(jq -n --arg var_value "$VAR_VALUE" '{"data":{"attributes":{"value":$var_value}}}')"

VAR_ID="$(update_var "$WORKSPACE_ID" "$VAR_ID" "$DATA" | jq -r '.data.id')"

echo "$VAR_ID"
