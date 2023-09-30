#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

export test_only

testActiveTable_initialized_A002() {

  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init

  # shellcheck disable=SC2154
  result=$(echo "$active_table" | head -c10)

  assertContains "active_table has content" "$result" "1"

  assertNotNull "active_table is set, $result" "[ -n $result ]"
}

# Load and run shUnit2.
. shunit2
