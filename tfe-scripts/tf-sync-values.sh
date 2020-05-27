#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <path_to_variables_file> <workspace_id>"
  echo "Usage: $0 <path_to_variables_file> <organization> <workspace_name>"
  exit 1
fi

pwd="$(dirname "$0")"
source "$pwd/helpers/tf-api.sh"

variable_file="$1"

if [ -z "$3" ]; then
  workspace_id="$2"
else
  organization_name="$2"
  workspace_name="$3"
  workspace_id="$(get_workspace_by_name "$organization_name" "$workspace_name" | jq -r '.data.id')"
fi

list_result="$(list_vars "$workspace_id")"

while IFS= read -r line; do
  var_key="$(cut -d'=' -f1 <<<"$line")"
  var_val="$(cut -d'=' -f2- <<<"$line")"

  if [ ! -z "$var_key" ] && [ ! -z "$var_val" ]; then
    if [ "$var_key" == "credentials_file" ]; then
      credentials_file="$var_val"
    elif [ "$var_key" == "kubernetes_token" ]; then
      kubernetes_token="$var_val"
    fi
  fi
done < <(grep . "${variable_file}")

rm "$variable_file"
touch "$variable_file"

if [ "$credentials_file" ]; then
  echo "credentials_file=${credentials_file}" >> "$variable_file"
fi

if [ "$kubernetes_token" ]; then
  echo "kubernetes_token=${kubernetes_token}" >> "$variable_file"
fi

kubernetes_host_data="$(echo "$list_result" | jq -r ".data[] | select(.attributes.key == \"kubernetes_host\") | .")"
kubernetes_host_value="$(echo "$kubernetes_host_data" | jq -r ".attributes.value")"

namespace_apps_data="$(echo "$list_result" | jq -r ".data[] | select(.attributes.key == \"namespace_apps\") | .")"
namespace_apps_value="$(echo "$namespace_apps_data" | jq -rc '.attributes.value | sub("[\\n\\s]";"";"g")')"

kubernetes_namespaces_data="$(echo "$list_result" | jq -r ".data[] | select(.attributes.key == \"kubernetes_namespaces\") | .")"
kubernetes_namespaces_value="$(echo "$kubernetes_namespaces_data" | jq -rc '.attributes.value | sub("[\\n\\s]";"";"g")')"

{
  echo "kubernetes_host=${kubernetes_host_value}"
  echo "namespace_apps=${namespace_apps_value}"
  echo "kubernetes_namespaces=${kubernetes_namespaces_value}"
} >> "$variable_file"
