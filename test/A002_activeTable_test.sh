#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testActiveTable_initialized_A002() {

  test_only=true

  . $commit_sh

  result=$(echo $active_table | head -c10)

  assertTrue "active_table is set, $result" "[ -n $result ]"
}

# Load and run shUnit2.
. shunit2
