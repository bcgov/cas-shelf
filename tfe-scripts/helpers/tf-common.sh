#!/bin/bash

is_error_response() {
  response="$1"
  errors="$(echo "$response" | jq -r ".errors")"

  if [ "$errors" != null ]; then
    error_status="$(echo "$errors" | jq -r ".[] .status")"
    error_msg="$(echo "$errors" | jq -r ".[] .title")"
    echo "$error_msg ($error_status)"
    return 0
  fi

  return 1
}

has_error_code() {
  response="$1"
  error_code="$2"

  errors="$(echo "$response" | jq -r ".errors")"

  if [ "$errors" != null ]; then
    error_status="$(echo "$errors" | jq -r ".[] .status")"

    if [ "$error_status" == "$error_code" ]; then
      error_msg="$(echo "$errors" | jq -r ".[] .title")"
      echo "$error_msg ($error_status)"
      return 0
    else
      return 1
    fi
  fi

  return 1
}

is_unauthorized() {
  if has_error_code "$1" "401"; then return 0; else return 1; fi
}

has_not_found() {
  if has_error_code "$1" "404"; then return 0; else return 1; fi
}
