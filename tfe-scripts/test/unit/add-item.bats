#!/usr/bin/env bats

load ../test_helper

setup() {
  sample_vars_data="$(cat "${BATS_TEST_DIRNAME}/../fixtures/example_vars.json")"
  target_key="variable_2"
  new_item="slug-env2,app2"
  expected="$(echo "[\"slug-env1,app1\",\"slug-env2,app2\"]" | jq ". | @base64")"
}

teardown() {
  if [ -z "$TEST_FUNCTION" ]; then
    shellmock_clean
  fi
}

@test "add a new item into json array parsed from a sample Terraform API response data" {
  data="$(echo "$sample_vars_data" | jq -r ".data[] | select(.attributes.key == \"$target_key\") | .")"
  list="$(echo "$data" | jq -r ".attributes.value")"
  result="$(echo "$list" | jq ". + [\"$new_item\"] | unique | @base64")"
  echo "output = $result"
  [ "$result" == "$expected" ]
}
