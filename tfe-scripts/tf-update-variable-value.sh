#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <workspace_id> <var_key> <var_value>"
  exit 1
fi

source "$(dirname "$0")/helpers/tf-api.sh"

workspace_id="$1"
var_key="$2"
var_value="$3"

list_result="$(list_vars "$workspace_id")"

var_data="$(echo "$list_result" | jq -r ".data[] | select(.attributes.key == \"$var_key\") | .")"
var_id="$(echo "$var_data" | jq -r ".id")"

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
# shellcheck disable=SC2016
data="$(jq -n --arg var_value "$var_value" '{"data":{"attributes":{"value":$var_value}}}')"

var_id="$(update_var "$workspace_id" "$var_id" "$data" | jq -r '.data.id')"

echo "variable $var_id updated"
