#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

export test_only

testEndArg_D003() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1_2 "--" "--" "id:5"

  # shellcheck disable=SC2154
  assertTrue "is_argument_1 is true" "$is_argument_1"
  # shellcheck disable=SC2154
  assertEquals "argument_1 equals \"\"" "" "$argument_1"
  # shellcheck disable=SC2154
  assertTrue "is_argument_2 is true" "$is_argument_2"
  # shellcheck disable=SC2154
  assertEquals "argument_2 equals \"\"" "" "$argument_2"
  # shellcheck disable=SC2154
  assertTrue "is_argument_3 is true" "$is_argument_3"
  # shellcheck disable=SC2154
  assertEquals "argument_3 equals \"\"" "id:5" "$argument_3"
}

# Load and run shUnit2.
. shunit2
