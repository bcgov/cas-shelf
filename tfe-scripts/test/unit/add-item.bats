#!/usr/bin/env bats

load ../test_helper

setup() {
  SAMPLE_VARS_DATA="$(cat "${BATS_TEST_DIRNAME}/../fixtures/example_vars.json")"
  TARGET_KEY="variable_2"
  NEW_ITEM="slug-env2,app2"
  EXPECTED="$(echo "[\"slug-env1,app1\",\"slug-env2,app2\"]" | jq ". | @base64")"
}

teardown() {
  if [ -z "$TEST_FUNCTION" ]; then
    shellmock_clean
  fi
}

@test "add a new item into json array parsed from a sample Terraform API response data" {
  data="$(echo "$SAMPLE_VARS_DATA" | jq -r ".data[] | select(.attributes.key == \"$TARGET_KEY\") | .")"
  list="$(echo "$data" | jq -r ".attributes.value")"
  result="$(echo "$list" | jq ". + [\"$NEW_ITEM\"] | unique | @base64")"
  echo "output = $result"
  [ "$result" == "$EXPECTED" ]
}
