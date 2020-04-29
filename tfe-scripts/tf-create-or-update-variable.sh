#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <path_to_payload_file> <workspace_id>"
  exit 0
fi

source "$(dirname "$0")/helpers/tf-api.sh"

PAYLOAD_FILE="$1"
WORKSPACE_ID="$2"

VAR_KEY="$(jq -r '.data.attributes.key' < "$PAYLOAD_FILE")"

if [ "$VAR_KEY" == null ]; then
  echo "variable key not found"
  exit 0
fi

VAR_ID="$(create_var "$WORKSPACE_ID" "$PAYLOAD_FILE" | base64 -d | jq -r '.data.id')"

if [ "$VAR_ID" != null ]; then
  echo "$VAR_ID"
  exit 0
fi

LIST_RESULT="$(list_vars "$WORKSPACE_ID")"

i=0
for key in $(echo "$LIST_RESULT" | base64 -d | jq -r '.data[] .attributes.key'); do
  if [ "${VAR_KEY[0]}" == "$key" ]; then
    break
  fi
  ((i = i + 1))
done

VAR_ID="$(echo "$LIST_RESULT" | base64 -d | jq -r ".data[$i] .id")"

VAR_ID="$(update_var "$WORKSPACE_ID" "$VAR_ID" "@${PAYLOAD_FILE}" | base64 -d | jq -r '.data.id')"

echo "$VAR_ID"
