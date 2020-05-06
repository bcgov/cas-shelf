#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <workspace_id> <variable_name> <item>"
  exit 1
fi

source "$(dirname "$0")/helpers/tf-api.sh"

workspace_id="$1"
variable_name="$2"
item="$3"

list_result="$(list_vars "$workspace_id")"
var_data="$(echo "$list_result" | jq -r ".data[] | select(.attributes.key == \"$variable_name\") | .")"
var_id="$(echo "$var_data" | jq -r ".id")"
value="$(echo "$var_data" | jq -r ".attributes.value")"
new_value="$(echo "$value" | jq ". + [\"$item\"] | unique")"

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
# shellcheck disable=SC2016
data="$(jq -n --arg new_value "$new_value" '{"data":{"attributes":{"value":$new_value}}}')"

var_id="$(update_var "$workspace_id" "$var_id" "$data" | jq -r '.data.id')"

echo "$var_id"
