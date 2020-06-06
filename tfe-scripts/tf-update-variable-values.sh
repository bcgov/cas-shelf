#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <path_to_variables_file> <workspace_id>"
  echo "Usage: $0 <path_to_variables_file> <organization> <workspace_name>"
  exit 1
fi

pwd="$(dirname "$0")"
source "$pwd/helpers/tf-api.sh"
source "$pwd/helpers/tf-common.sh"

variable_file="$1"

if [ -z "$3" ]; then
  workspace_id="$2"
else
  organization_name="$2"
  workspace_name="$3"
  workspace_response="$(get_workspace_by_name "$organization_name" "$workspace_name")"

  if is_error_response "$workspace_response"; then exit 1; fi
  workspace_id="$(echo "$workspace_response" | jq -r '.data.id')"
fi

update_value() {
  "$pwd"/tf-update-variable-value.sh "$workspace_id" "$1" "$2"
}

while IFS= read -r line; do
  var_key="$(cut -d'=' -f1 <<<"$line")"
  var_val="$(cut -d'=' -f2- <<<"$line")"

  if [ ! -z "$var_key" ] && [ ! -z "$var_val" ]; then
    if [ "$var_key" == "namespace_apps" ]; then
      namespace_apps="$(echo "$var_val" | jq ". | unique")"
      update_value "namespace_apps" "$namespace_apps"

    elif [ "$var_key" == "kubernetes_namespaces" ]; then
      kubernetes_namespaces="$(echo "$var_val" | jq ". | unique")"
      update_value "kubernetes_namespaces" "$kubernetes_namespaces"

    elif [ "$var_key" == "credentials_file" ]; then
      project_id="$(jq -r '.project_id' <"$var_val")"
      client_email="$(jq -r '.client_email' <"$var_val")"

      # read value as json string to have new line characters as it is
      # and strip first and last characters which are double quotes
      private_key="$(jq '.private_key' <"$var_val")"
      length=${#private_key}-2
      private_key=${private_key:1:$length}

      update_value "project_id" "$project_id"
      update_value "credentials_client_email" "$client_email"
      update_value "credentials_private_key" "$private_key"
    else
      update_value "$var_key" "$var_val"
    fi
  fi
done < <(grep . "${variable_file}")

update_value "terraform_cloud_workspace_id" "$workspace_id"
update_value "terraform_cloud_token" "$TFC_TOKEN"
