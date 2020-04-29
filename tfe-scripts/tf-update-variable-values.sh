#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <path_to_variables_file> <workspace_id>"
  echo "Usage: $0 <path_to_variables_file> <organization> <workspace_name>"
  exit 1
fi

PWD="$(dirname "$0")"
source "$PWD/helpers/tf-api.sh"

VARIABLE_FILE="$1"

if [ -z "$3" ]; then
  WORKSPACE_ID="$2"
else
  ORGANIZATION_NAME="$2"
  WORKSPACE_NAME="$3"
  WORKSPACE_ID="$(get_workspace_by_name "$ORGANIZATION_NAME" "$WORKSPACE_NAME" | jq -r '.data.id')"
fi

update_value() {
  "$PWD"/tf-update-variable-value.sh "$WORKSPACE_ID" "$1" "$2"
}

while IFS= read -r line; do
  var_key="$(cut -d'=' -f1 <<<"$line")"
  var_val="$(cut -d'=' -f2- <<<"$line")"

  if [ ! -z "$var_key" ] && [ ! -z "$var_val" ]; then
    if [ "$var_key" == "namespace_apps" ]; then
      namespace_apps="$(echo "$var_val" | jq ". | unique")"
      kubernetes_namespaces="$(echo "$namespace_apps" | jq 'map(. | split(",")[0]) | unique')"

      update_value "namespace_apps" "$namespace_apps"
      update_value "kubernetes_namespaces" "$kubernetes_namespaces"

    elif [ "$var_key" == "credentials_file" ]; then
      project_id="$(jq -r '.project_id' < "$var_val")"
      client_email="$(jq -r '.client_email' < "$var_val")"

      # read value as json string to have new line characters as it is
      # and strip first and last characters which are double quotes
      private_key="$(jq '.private_key' < "$var_val")"
      length=${#private_key}-2
      private_key=${private_key:1:$length}

      update_value "project_id" "$project_id"
      update_value "credentials_client_email" "$client_email"
      update_value "credentials_private_key" "$private_key"
    else
      update_value "$var_key" "$var_val"
    fi
  fi
done < <(grep . "${VARIABLE_FILE}")

update_value "terraform_cloud_workspace_id" "$WORKSPACE_ID"
update_value "terraform_cloud_token" "$TFC_TOKEN"
