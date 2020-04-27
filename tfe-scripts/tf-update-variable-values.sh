#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <path_to_variables_file> <workspace_id>"
  echo "Usage: $0 <path_to_variables_file> <organization> <workspace_name>"
  exit 0
fi

VARIABLE_FILE=$1

if [ -z "$3" ]; then
  WORKSPACE_ID=$2
else
  ORGANIZATION_NAME="$2"
  WORKSPACE_NAME="$3"
  WORKSPACE_ID=($(curl \
    --header "Authorization: Bearer $TFC_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    https://app.terraform.io/api/v2/organizations/$ORGANIZATION_NAME/workspaces/$WORKSPACE_NAME |
    jq -r '.data.id'))
fi

while IFS= read -r line; do
  var_key="$(cut -d'=' -f1 <<<"$line")"
  var_val="$(cut -d'=' -f2- <<<"$line")"

  if [ ! -z "$var_key" ] && [ ! -z "$var_val" ]; then
    if [ $var_key == "namespace_apps" ]; then
      # create double quote escaped namespace_apps array string and collect namespaces
      namespaces=()
      namespace_apps="["
      i=0
      for value in $(echo "${var_val}" | jq -r '.[]'); do
        namespaces+=( "$(cut -d',' -f1 <<<"$value")" )
        if [ $i -ne 0 ]; then namespace_apps=$namespace_apps","; fi
        namespace_apps=$namespace_apps\\\"$value\\\"
        ((i = i + 1))
      done
      namespace_apps=$namespace_apps"]"

      uniq_namespaces=($(printf "%s\n" "${namespaces[@]}" | sort -u | tr '\n' ' '))

      # create double quote escaped unique namespace array string
      kubernetes_namespaces="["
      i=0
      for namespace in "${uniq_namespaces[@]}"; do
        if [ $i -ne 0 ]; then kubernetes_namespaces=$kubernetes_namespaces","; fi
        kubernetes_namespaces=$kubernetes_namespaces\\\"$namespace\\\"
        ((i = i + 1))
      done
      kubernetes_namespaces=$kubernetes_namespaces"]"

      ./tfe-scripts/tf-update-variable-value.sh "$WORKSPACE_ID" "namespace_apps" "$namespace_apps"
      ./tfe-scripts/tf-update-variable-value.sh "$WORKSPACE_ID" "kubernetes_namespaces" "$kubernetes_namespaces"
    else
      ./tfe-scripts/tf-update-variable-value.sh "$WORKSPACE_ID" "$var_key" "$var_val"
    fi
  fi
done < <(grep . "${VARIABLE_FILE}")

./tfe-scripts/tf-update-variable-value.sh "$WORKSPACE_ID" "terraform_cloud_workspace_id" "$WORKSPACE_ID"
./tfe-scripts/tf-update-variable-value.sh "$WORKSPACE_ID" "terraform_cloud_token" "$TFC_TOKEN"
