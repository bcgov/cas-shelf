#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <path_to_payload_file> <workspace_id>"
  exit 1
fi

source "$(dirname "$0")/helpers/tf-api.sh"

payload_file="$1"
workspace_id="$2"

var_key="$(jq -r '.data.attributes.key' < "$payload_file")"

if [ "$var_key" == null ]; then
  echo "variable key not found"
  exit 1
fi

var_id="$(create_var "$workspace_id" "$payload_file" | jq -r '.data.id')"

if [ "$var_id" != null ]; then
  echo "variable $var_id created"
  exit 0
fi

list_result="$(list_vars "$workspace_id")"

var_data="$(echo "$list_result" | jq -r ".data[] | select(.attributes.key == \"$var_key\") | .")"
var_id="$(echo "$var_data" | jq -r ".id")"

var_id="$(update_var "$workspace_id" "$var_id" "@${payload_file}" | jq -r '.data.id')"

echo "variable $var_id updated"
