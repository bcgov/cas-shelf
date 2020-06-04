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

list_result="$(list_vars "$TFC_WORKSPACE_ID")"

errors="$(echo "$list_result" | jq -r ".errors")"

if [ "$errors" != null ]; then
  error_status="$(echo "$errors" | jq -r ".[] .status")"
  error_msg="$(echo "$errors" | jq -r ".[] .title")"
  echo "$error_msg ($error_status)"
  exit 1
fi

napespace_apps_data="$(echo "$list_result" | jq -r ".data[] | select(.attributes.key == \"$namespace_apps_key\") | .")"
namespace_apps_id="$(echo "$napespace_apps_data" | jq -r ".id")"

if [ -z "$namespace_apps_id" ] || [ "$namespace_apps_id" == null ]; then
  echo "variable $namespace_apps_key not found"
  exit 1
fi

# update `namespace_apps`
napespace_apps_value="$(echo "$napespace_apps_data" | jq -r ".attributes.value")"
napespace_apps_new_value="$(echo "$napespace_apps_value" | jq ". + [\"$namespace_app\"] | unique")"

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
# shellcheck disable=SC2016
napespace_apps_data_to_update="$(jq -n --arg new_value "$napespace_apps_new_value" '{"data":{"attributes":{"value":$new_value}}}')"

namespace_apps_id="$(update_var "$TFC_WORKSPACE_ID" "$namespace_apps_id" "$napespace_apps_data_to_update" | jq -r '.data.id')"

# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
# shellcheck disable=SC2016
run_payload="$(jq -n --arg workspace_id "$TFC_WORKSPACE_ID" '{"data":{"type":"runs","relationships":{"workspace":{"data":{"type":"workspaces","id":$workspace_id}}}}}')"

run_id="$(create_run "$run_payload" | jq -r '.data.id')"

if [ "$run_id" == null ]; then
  echo "failed to create a run"
  exit 1
fi

echo "run $run_id created"

# see https://github.com/hashicorp/go-tfe/blob/master/run.go#L49 for all available run statuses.
completed_statuses=(null "applied" "canceled" "discarded" "planned_and_finished")
errored_statuses=("errored" "policy_soft_failed")

count=0
get_status() {
  status="$(get_run "$run_id" | jq -r '.data.attributes.status')"
  echo "run status - $status"

  # disable shellcheck to match literally
  # shellcheck disable=SC2076
  if [[ "${completed_statuses[@]}" =~ "$status" ]]; then
    return 1
  fi

  # disable shellcheck to match literally
  # shellcheck disable=SC2076
  if [[ "${errored_statuses[@]}" =~ "$status" ]]; then
    exit 1
  fi

  if [[ "$count" -gt 50 ]]; then
    echo "timed out"
    exit 1
  fi

  count=$((count + 1))
}

while get_status; do sleep 5; done
