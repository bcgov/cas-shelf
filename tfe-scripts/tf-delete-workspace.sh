#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <organization> <workspace>"
  exit 1
fi

source "$(dirname "$0")/helpers/tf-api.sh"

organization_name="$1"
workspace_name="$2"

delete_workspace_by_name "$organization_name" "$workspace_name"
