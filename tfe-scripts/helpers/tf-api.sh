#!/bin/bash

readonly AUTHORIZATION="Authorization: Bearer $TFC_TOKEN"
readonly CONTENT_TYPE="Content-Type: application/vnd.api+json"
readonly BASE_URL="https://app.terraform.io/api/v2"

get_workspace_by_name() {
  organization_name="$1"
  workspace_name="$2"

  curl -s \
  --header "$AUTHORIZATION" \
  --header "$CONTENT_TYPE" \
  "${BASE_URL}/organizations/${organization_name}/workspaces/${workspace_name}"
}

create_workspace() {
  organization_name="$1"
  data="$2"

  curl -s \
  --header "$AUTHORIZATION" \
  --header "$CONTENT_TYPE" \
  --request POST \
  --data "$data" \
  "${BASE_URL}/organizations/${organization_name}/workspaces"
}

delete_workspace_by_name() {
  organization_name="$1"
  workspace_name="$2"

  curl -s \
  --header "$AUTHORIZATION" \
  --header "$CONTENT_TYPE" \
  --request DELETE \
  "${BASE_URL}/organizations/${organization_name}/workspaces/${workspace_name}"
}

list_vars() {
  workspace_id="$1"

  curl -s \
  --header "$AUTHORIZATION" \
  --header "$CONTENT_TYPE" \
  "${BASE_URL}/workspaces/${workspace_id}/vars"
}

create_var() {
  workspace_id="$1"
  PAYLOAD_FILE="$2"

  curl -s \
  --header "$AUTHORIZATION" \
  --header "$CONTENT_TYPE" \
  --request POST \
  --data @"$PAYLOAD_FILE" \
  "${BASE_URL}/workspaces/${workspace_id}/vars"
}

update_var() {
  workspace_id="$1"
  var_id="$2"
  data="$3"

  curl -s \
  --header "$AUTHORIZATION" \
  --header "$CONTENT_TYPE" \
  --request PATCH \
  --data "${data}" \
  "${BASE_URL}/workspaces/${workspace_id}/vars/${var_id}"
}

create_run() {
  data="$1"

  curl -s \
  --header "$AUTHORIZATION" \
  --header "$CONTENT_TYPE" \
  --request POST \
  --data "${data}" \
  "${BASE_URL}/runs"
}

get_run() {
  run_id="$1"

  curl -s \
  --header "$AUTHORIZATION" \
  "${BASE_URL}/runs/${run_id}"
}

create_configuration() {
  workspace_id="$1"
  data="$2"

  curl -s \
  --header "$AUTHORIZATION" \
  --header "$CONTENT_TYPE" \
  --request POST \
  --data "${data}" \
  "${BASE_URL}/workspaces/${workspace_id}/configuration-versions"
}

upload_configuration() {
  upload_url="$1"
  upload_file_name="$2"

  curl -s \
  --header "Content-Type: application/octet-stream" \
  --request PUT \
  --data-binary "@${upload_file_name}" \
  "${upload_url}"
}
