#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <organization> <workspace>"
  exit 1
fi

source "$(dirname "$0")/helpers/tf-api.sh"

ORGANIZATION_NAME="$1"
WORKSPACE_NAME="$2"

delete_workspace_by_name "$ORGANIZATION_NAME" "$WORKSPACE_NAME"
