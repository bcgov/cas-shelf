#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <path_to_payload_file> <workspace_id>"
  exit 1
fi

source "$(dirname "$0")/helpers/tf-api.sh"

PAYLOAD_FILE="$1"
WORKSPACE_ID="$2"

VAR_KEY="$(jq -r '.data.attributes.key' < "$PAYLOAD_FILE")"

if [ "$VAR_KEY" == null ]; then
  echo "variable key not found"
  exit 1
fi

VAR_ID="$(create_var "$WORKSPACE_ID" "$PAYLOAD_FILE" | jq -r '.data.id')"

if [ "$VAR_ID" != null ]; then
  echo "$VAR_ID"
  exit 0
fi

LIST_RESULT="$(list_vars "$WORKSPACE_ID")"

VAR_DATA="$(echo "$LIST_RESULT" | jq -r ".data[] | select(.attributes.key == \"$VAR_KEY\") | .")"
VAR_ID="$(echo "$VAR_DATA" | jq -r ".id")"

VAR_ID="$(update_var "$WORKSPACE_ID" "$VAR_ID" "@${PAYLOAD_FILE}" | jq -r '.data.id')"

echo "$VAR_ID"
