#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <namespace> <app>"
  exit 1
fi

source "$(dirname "$0")/helpers/tf-api.sh"

namespace="$1"
app="$2"
namespace_app="${namespace},${app}"

namespace_apps_key="namespace_apps"
namespaces_key="kubernetes_namespaces"

list_result="$(list_vars "$TFC_WORKSPACE_ID")"

if [ "$list_result" == null ]; then
  echo "invalid workspace"
  exit 1
fi

napespace_apps_data="$(echo "$list_result" | jq -r ".data[] | select(.attributes.key == \"$namespace_apps_key\") | .")"
namespace_apps_id="$(echo "$napespace_apps_data" | jq -r ".id")"

namespaces_data="$(echo "$list_result" | jq -r ".data[] | select(.attributes.key == \"$namespaces_key\") | .")"
namespaces_id="$(echo "$namespaces_data" | jq -r ".id")"

if [ "$namespace_apps_id" == null ]; then
  echo "variable $namespace_apps_key not found"
  exit 1
fi

if [ "$namespaces_id" == null ]; then
  echo "variable $namespaces_key not found"
  exit 1
fi

# update `namespace_apps`
napespace_apps_value="$(echo "$napespace_apps_data" | jq -r ".attributes.value")"
napespace_apps_new_value="$(echo "$napespace_apps_value" | jq ". + [\"$namespace_app\"] | unique")"

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
# shellcheck disable=SC2016
napespace_apps_data_to_update="$(jq -n --arg new_value "$napespace_apps_new_value" '{"data":{"attributes":{"value":$new_value}}}')"

namespace_apps_id="$(update_var "$TFC_WORKSPACE_ID" "$namespace_apps_id" "$napespace_apps_data_to_update" | jq -r '.data.id')"

echo "$namespace_apps_id"

# update `kubernetes_namespaces`
namespaces_value="$(echo "$namespaces_data" | jq -r ".attributes.value")"
namespaces_new_value="$(echo "$namespaces_value" | jq ". + [\"$namespace\"] | unique")"

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
# shellcheck disable=SC2016
napespaces_data_to_update="$(jq -n --arg new_value "$namespaces_new_value" '{"data":{"attributes":{"value":$new_value}}}')"

namespaces_id="$(update_var "$TFC_WORKSPACE_ID" "$namespaces_id" "$napespaces_data_to_update" | jq -r '.data.id')"

echo "$namespaces_id"

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
# shellcheck disable=SC2016
run_payload="$(jq -n --arg workspace_id "$TFC_WORKSPACE_ID" '{"data":{"type":"runs","relationships":{"workspace":{"data":{"type":"workspaces","id":$workspace_id}}}}}')"

run_id="$(create_run "$run_payload" | jq -r '.data.id')"

get_status() {
  status="$(get_run "$run_id" | jq -r '.data.attributes.status')"

  if [ "$status" == "errored" ]; then return 1; fi
  if [ "$status" == "discarded" ]; then return 1; fi
  if [ "$status" == "applied" ]; then return 1; fi
  if [ "$status" == "planned_and_finished" ]; then return 1; fi
}

while get_status; do sleep 5; done

echo "$status"
