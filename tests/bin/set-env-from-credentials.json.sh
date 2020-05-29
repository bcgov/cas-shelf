#!/bin/bash

pwd="$(dirname "$0")"

credentials_file="$pwd/../credentials.json"
env_file="$pwd/../.env"

if [ -f "$credentials_file" ]; then
  credentials="$(jq -c '.' <"$credentials_file")"
  project_id="$(jq -r '.project_id' <"$credentials_file")"

  rm "$env_file"
  touch "$env_file"

  {
    echo "TF_VAR_credentials=${credentials}"
    echo "TF_VAR_project_id=${project_id}"
  } >> "$env_file"
fi
